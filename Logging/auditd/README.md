# Guide for auditd logging

## Important SYSCALL

- File Operations:
  - `read, write`:Read from or write to a file descriptor.
  - `open, close`:Open or close a file.
  - `lstat, stat, fstat`:Retrieve information about a file.
  - `chmod, chown`:Change file permissions or ownership.
- Process Management:
  - `fork, vfork, clone`:Create a new process.
  - `wait4, exit, exit_group`:Wait for a process to finish or terminate a process.
  - `getpid, getppid`:Retrieve the process ID of the caller or its parent.
- Memory Management:
  - `mmap, munmap`:Map or unmap files or devices into memory.
  - `mprotect`:Set protection on a region of memory.
  - `mlock, munlock`:Lock or unlock memory regions.
- Network Operations:
  - `socket, bind, connect`:Create, bind, or connect a socket.
  - `sendto, recvfrom`:Send or receive messages from a socket.
- Time Management:
  - `gettimeofday, settimeofday`:Get or set the current time or timezone.
  - `nanosleep`:High-resolution sleep.
- Security and User Management:
  - `getuid, setuid`:Get or set the user ID.
  - `getgid, setgid`:Get or set the group ID.
- System Control and Information:
  - `uname`:Get system information.
  - `sysinfo`:Retrieve system statistics.
  - `reboot`:Reboot the system.
- Advanced Operations and Virtualization:
  - `pivot_root`:Change the root filesystem.
  - `chroot`:Change the root directory.
  - `unshare`:Disassociate parts of the process execution context.
- Kernel Module Operations:
  - `init_module, delete_module`:Insert or remove a kernel module.
- Filesystem Operations:
  - `mount, umount2`:Mount or unmount filesystems.
- Real-time Signals and Synchronization:
  - `rt_sigaction, rt_sigprocmask`:Examine and change blocked signals or signal action.
  - `semget, semop`:System V semaphore operations.
- Newer and Miscellaneous Operations:
  - `getrandom`:Obtain random bytes.
  - `bpf`:Perform various operations on BPF maps and programs.
  - `io_uring_setup, io_uring_enter`:Efficient I/O operations using io_uring.

## ALL SYSCALL descriptions:

<details>
todo
</details>
