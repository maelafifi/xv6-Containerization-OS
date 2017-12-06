# Saman Dalo and Mohamed Elafifi
## xv6 Containerization

The purpose of this project is implement containerization through file system 
and process isolation on the xv6, unix-like operating system. Once a container
is initialized, users will only be able to access files and processes from 
within the scope of the container. All other files and processes are completely
off limits to the user when working in a container environment. 

# Implementation
Just all about all aspects of the project were built on the following struct:

struct container{ 
	int max_mem, max_proc, max_disk; // container consumption limits
	int curr_mem, curr_proc, curr_disk; // container current consumption
	char name[32]; // container name
	struct inode* root; // inode information for file system isolation
};

## ps
The ps program provides information about the currently running processes. In 
root, the ps program will display all currently running processes, including 
root and container processes. Within a container, ps only has the ability to 
show details about processes that are currently running within the container.
This was implemented similarly to the procdump() function in proc.c, with an 
added check to see if a process should be displayed or not.
## free
Free provides realtime information about current RAM usage. The progra displays
the total amount of currently used memory out of the total available memory 
available to the machine or container. This was done through the use of a simple
counter variable; everytime kalloc is called, a page is allocated, increasing 
memory consumption. Everytime kfree is called, a page becomes available, reducing
memory consumption. In root, free will display all current consumption, including
container consumption. Within a container, it will show all consumption for the 
container itself and will compare against the total amount of memory allocated for
the container.
## df
The df tool provides information about the total disk usage. In root, you will see
total disk usage. Within a container, you will see disk usage for the given container 
compared against the total amount of disk space allocated for the given container. On 
start, df is implemented similar to the ls user level program, with an added recursive 
functionality to open a "file" if it is a directory. It essentially counts all of the 
bytes currently being used by any and all files and directories on a given system. After
start, book keeping for the disk usage is done inside of writei (for increasing disk 
usage) or inside of unlink (for decreasing disk usage).
## ctool
All of the below functionalities belong to the ctool user level program. While 
ctool commands have the ability to run within the container, they were created
to be run from the root. 
### create
Create a directory, and add all the files that a user wants to have within his
or her container. Once created, users stiil have the ability to add files into 
the directory if they are in the root container. 
### start
Start starts a container. Parameters given to start include memory, disk, and 
process limitations. Once started, a user can only execute what is available 
within the container itself. 
### stop
Stop stops a container. All processes are killed, and all other resources are 
freed.
### pause
Pause pauses a container, preventing all of its processes from running. Resources
remain allocated to the container.
### resume
Resume resumes a container, setting all of its processes back to a runnable state.
### info
Info provides information about the currently running containers, including the 
consumption of a given process for a particular container. 




xv6 is a re-implementation of Dennis Ritchie's and Ken Thompson's Unix
Version 6 (v6).  xv6 loosely follows the structure and style of v6,
but is implemented for a modern x86-based multiprocessor using ANSI C.

ACKNOWLEDGMENTS

xv6 is inspired by John Lions's Commentary on UNIX 6th Edition (Peer
to Peer Communications; ISBN: 1-57398-013-7; 1st edition (June 14,
2000)). See also http://pdos.csail.mit.edu/6.828/2016/xv6.html, which
provides pointers to on-line resources for v6.

xv6 borrows code from the following sources:
    JOS (asm.h, elf.h, mmu.h, bootasm.S, ide.c, console.c, and others)
    Plan 9 (entryother.S, mp.h, mp.c, lapic.c)
    FreeBSD (ioapic.c)
    NetBSD (console.c)

The following people have made contributions: Russ Cox (context switching,
locking), Cliff Frey (MP), Xiao Yu (MP), Nickolai Zeldovich, and Austin
Clements.

We are also grateful for the bug reports and patches contributed by Silas
Boyd-Wickizer, Anton Burtsev, Cody Cutler, Mike CAT, Tej Chajed, Nelson Elhage,
Saar Ettinger, Alice Ferrazzi, Nathaniel Filardo, Peter Froehlich, Yakir Goaron,
Shivam Handa, Bryan Henry, Jim Huang, Alexander Kapshuk, Anders Kaseorg,
kehao95, Wolfgang Keller, Eddie Kohler, Austin Liew, Imbar Marinescu, Yandong
Mao, Hitoshi Mitake, Carmi Merimovich, Joel Nider, Greg Price, Ayan Shafqat,
Eldar Sehayek, Yongming Shen, Cam Tenny, Rafael Ubal, Warren Toomey, Stephen Tu,
Pablo Ventura, Xi Wang, Keiichi Watanabe, Nicolas Wolovick, Grant Wu, Jindong
Zhang, Icenowy Zheng, and Zou Chang Wei.

The code in the files that constitute xv6 is
Copyright 2006-2016 Frans Kaashoek, Robert Morris, and Russ Cox.

ERROR REPORTS

Please send errors and suggestions to Frans Kaashoek and Robert Morris
(kaashoek,rtm@mit.edu). The main purpose of xv6 is as a teaching
operating system for MIT's 6.828, so we are more interested in
simplifications and clarifications than new features.

BUILDING AND RUNNING XV6

To build xv6 on an x86 ELF machine (like Linux or FreeBSD), run
"make". On non-x86 or non-ELF machines (like OS X, even on x86), you
will need to install a cross-compiler gcc suite capable of producing
x86 ELF binaries. See http://pdos.csail.mit.edu/6.828/2016/tools.html.
Then run "make TOOLPREFIX=i386-jos-elf-". Now install the QEMU PC
simulator and run "make qemu".
