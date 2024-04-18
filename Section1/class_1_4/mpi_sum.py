# A parallel sum

from mpi4py import MPI

comm = MPI.COMM_WORLD
worker = comm.Get_rank()
size = comm.Get_size()

a=3

if(worker == 0):
    print(size," processes started!")
    comm.send(a, dest=worker+1)
    print(worker," I am sending: ",a)
elif worker == size-1:
    rec = comm.recv(source=worker-1)
    print(worker," my step is ",rec+3)
else:
    rec = comm.recv(source=worker-1)
    comm.send(rec+3,dest=worker+1)

print(worker," my step is ",rec+3)