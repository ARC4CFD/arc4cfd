####   Jacobi Iteration of Steady Heat Conduction equation Using MPI    #######

##  A rectangular domain with fixed boundary temperatures, is subject to
##  heat source at centre of the domain

import time
from mpi4py import MPI
import numpy as np
import matplotlib.pyplot as plt


def split_rows(rows, size):
#ref: https://stackoverflow.com/questions/55465884/how-to-divide-an-unknown-integer-into-a-given-number-of-even-parts-using-python
#This function splits the rows into near equal parts
    avg_rows, remainder = divmod(rows, size)
    lower = [avg_rows for i in range(size - remainder)]
    higher = [avg_rows + 1 for j in range(remainder)]
    return np.array(lower + higher)

def main():

    comm=MPI.COMM_WORLD
    rank=comm.Get_rank()
    size=comm.Get_size()
    start_time=time.time()  #start timing

    if rank==0:

##################    USER INPUT STARTS    ####################################

        # Rectangular domain description     # All inputs in SI units
        x_length            = 0.06
        y_length            = 0.04
        x_nodes             = 60
        y_nodes             = 40

        # Initial and Boundary Conditions   # All inputs in SI units
        T_initial           = 300
        T_top               = 700
        T_right             = 400
        T_bottom            = 500
        T_left              = 600


        Q_source            = 3000           # Heat Source at centre of domain
        therm_cond          = 10             # Thermal conductivity of material

        # Execution conditions
        iterations = 4000
        epsilon = 1e-2

#####################      USER INPUT ENDS       ##############################

        # Select rows as with maximum interior points since we split row-wise
        rows = max(x_nodes,y_nodes) + 2      # Adding boundary points in x axis
        cols = min(x_nodes,y_nodes) + 2      # Adding boundary points in y axis
        dx = x_length/(x_nodes+1)
        dy = y_length/(y_nodes+1)


        # Initial and Boundary Conditions :
          ##  In this code, rows are chosen to be scattered into different processors
          ##  Hence, arrays are defined such that maximum nodes are in the rows
        T_initial = np.ones([rows,cols])*T_initial
        Q = np.zeros([rows,cols])
        Q[rows//2,cols//2] = Q_source
        if rows == x_nodes + 2:
            T_initial[0,:]  = T_left
            T_initial[-1,:] = T_right
            T_initial[:,0]  = T_bottom
            T_initial[:,-1] = T_top
        else:                 ##  Condition when rows and colums are flipped
            T_initial[0,:]  = T_bottom
            T_initial[-1,:] = T_top
            T_initial[:,0]  = T_left
            T_initial[:,-1] = T_right
        T_final = T_initial.copy()

        ###########   Generating inputs for Scatterv method  ################
        ##  Variables here are used in Scatterv call (lines 110, 111)
        local_row_counts=split_rows(rows, size)
        local_node_counts = local_row_counts*cols
        displacements = np.insert(np.cumsum(local_node_counts),0,0)[0:-1]
        ##  displacements: list containing element pointers in original matrix that indicate start of scattering
        ##  local_row_counts: row count of scattered matrix in respective processors
        ##  local_node_counts: total element count of scattered matrix in respective processors


    else:
    #Create dummy variables on other cores
        x_nodes,y_nodes = None,None
        cols = int
        local_row_counts = None
        local_node_counts = None
        displacements = None
        T_initial, T_final, Q, therm_cond = None, None, None, None
        dx,dy = None,None
        iterations, epsilon = None, None

    ##  Broadcasting common variables to dummy variables in other cores
    x_nodes = comm.bcast(x_nodes, root=0)
    y_nodes = comm.bcast(y_nodes, root=0)
    cols = comm.bcast(cols, root=0)
    dx = comm.bcast(dx, root=0)
    dy = comm.bcast(dy, root=0)
    therm_cond = comm.bcast(therm_cond, root=0)
    iterations = comm.bcast(iterations, root=0)
    epsilon = comm.bcast(epsilon, root=0)
    local_row_counts = comm.bcast(local_row_counts, root = 0)
    local_node_counts = comm.bcast(local_node_counts, root = 0)
    displacements = comm.bcast(displacements, root = 0)

    ##  Scattering T_initial and Q matrices to respective cores
    local_rows = local_row_counts[rank]
    T_local = np.zeros([local_rows, cols])
    Qsource = np.zeros(np.shape(T_local))
    comm.Scatterv([T_initial,local_node_counts, displacements,MPI.DOUBLE],T_local,root=0)
    comm.Scatterv([Q,local_node_counts, displacements,MPI.DOUBLE],Qsource,root=0)

    ##  Adding boundaries to T_local and Qsource matrices in each core using pad
    ##  Ideally, padding in Qsource is not needed as there is no inter-processor communication for Qsource.
    ##  however, doing it makes programming simpler, without much expense.
    if size != 1:
        if rank==0:
            T_local = np.pad(T_local, ((0, 1), (0, 0)),mode='constant', constant_values=300)
            Qsource = np.pad(Qsource, ((0, 1), (0, 0)),mode='constant', constant_values=0)
        elif rank==size-1:
            T_local = np.pad(T_local, ((1, 0), (0, 0)),mode='constant', constant_values=300)
            Qsource = np.pad(Qsource, ((1, 0), (0, 0)),mode='constant', constant_values=0)
        else:
            T_local = np.pad(T_local, ((1, 1), (0, 0)),mode='constant', constant_values=300)
            Qsource = np.pad(Qsource, ((1, 1), (0, 0)),mode='constant', constant_values=0)

    comm.Barrier()

    #####      Jacobi Iteration Starts     ####################################
    T_local_new = T_local.copy()

    for iter in range(0,iterations):

        L2norm_sq_node=0

        # Perform calculations
        if not (len(T_local)==2 and (rank==0 or rank==size-1)):
            # if first or last core has only two rows, no updating needed
            for i in range(1, len(T_local)-1):
                for j in range(1, cols-1):

                    ##  Dicretized terms of Heat conduction equation:
                    ##  Based on row count, x and y axis interchange, hence dx and dy interchange
                    if x_nodes >= y_nodes:
                        term1 = dy**2 * (T_local[i-1, j] + T_local[i+1, j])
                        term2 = dx**2 * (T_local[i, j-1] + T_local[i, j+1])
                    else:
                        term1 = dx**2 * (T_local[i-1, j] + T_local[i+1, j])
                        term2 = dy**2 * (T_local[i, j-1] + T_local[i, j+1])

                    term3 = dx * dy * Qsource[i, j] / therm_cond
                    coeff = 1/(2*(dx**2+dy**2))

                    T_local_new[i, j] = coeff * (term1 + term2 + term3)
                    L2norm_sq_node += (T_local_new[i, j]-T_local[i, j])**2   ##  Term to calculate L2 norm

        T_local=T_local_new.copy()

        # Updating boundaries in each node
        if rank > 0:
            comm.Send(T_local[1,:],dest=rank-1,tag=11)
            comm.Recv(T_local[0,:],source=rank-1,tag=22)
        if rank < size-1:
            comm.Recv(T_local[-1,:],source=rank+1,tag=11)
            comm.Send(T_local[-2,:],dest=rank+1,tag=22)

        # Convergence Criteria
        L2_norm=comm.allreduce(L2norm_sq_node,op=MPI.SUM)
        L2_norm = np.sqrt(L2_norm)

        if L2_norm < epsilon:
            break

    comm.Barrier()
    #####      Jacobi Iteration Ends     ####################################


    # removing pad boundaries from final solution in each core
    if size != 1:
        if rank==0:
            T_local = T_local[:-1,:]
        elif rank==size-1:
            T_local = T_local[1:,:]
        else:
            T_local = T_local[1:-1,:]

    comm.Barrier()

    ##  Gathering final solution from all cores
    comm.Gatherv(T_local,[T_final,local_node_counts,displacements,MPI.DOUBLE], root=0)

    ## Post-Processing
    if rank == 0:

        endTime=time.time() - start_time

        ##  Rearranging solution for plotting purpose
        if x_nodes >= y_nodes:
            T_final = np.transpose(T_final)

        ##  Generating meshgrid for plotting
        x = np.linspace(0, x_length, x_nodes+2)
        y = np.linspace(0, y_length, y_nodes+2)
        X, Y = np.meshgrid(x, y)

        disp_text = ['Nodes: ', rows*cols, ' Cores: ', size, \
                  ' Computation Time: ', round(endTime,6), ' sec']
        print(disp_text)
        print('Number of iterations: ', iter)

        # Writing T_final to .csv file. T_final includes padded boundary nodes.
        # Format : top row = T_top, left column = T_left and so on.
        save_text = [str(rows*cols)+'_'+str(size)+'.csv']
        save_solution = np.round(T_final,2)
        np.savetxt(save_text[0],save_solution,delimiter=",",fmt='%10.5f')

if __name__ == '__main__':
    main()