# File Integrity Monitoring with Auditd

## FIM ? PCI DSS ? 
- File Integrity Monitoring (FIM) is a security process that involves the regular monitoring and detection of changes in files, including system files, configurations, and content files. It is crucial in ensuring that files have not been tampered with, corrupted, or otherwise altered in an unauthorized manner.
- Payment Card Industry Data Security Standard (PCI DSS) is a set of security standards designed to ensure that all companies that accept, process, store, or transmit credit card information maintain a secure environment. Implementing FIM is vital for both general security hygiene and for compliance with regulations like PCI DSS.
 
In the context of PCI DSS, FIM helps protect sensitive payment data by detecting unauthorized changes to files that could indicate a breach or other security incident. This aligns with the goal of PCI DSS to safeguard cardholder information and helps organizations meet specific requirements within the standard.

## Auditd
Auditd is the user-space component of the Linux auditing system, responsible for writing audit records to the disk. It plays a crucial role in monitoring security-relevant activities on a system by tracking and logging specific system calls, file and directory accesses, authentication attempts, and more.
While various tools offer FIM capabilities, in this post, we'll explore how to set up and use auditd as a FIM.

### SYSCALLS
There is hundreds of syscalls, you can refer to these syscall tables for the complete lists: https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md

which syscalls are the relevant to keep in my auditd configuration for files modifications on my system ?

- In terminal 1 : `echo $$` gives me the pid of my terminal

#### Testing with [procmon](https://github.com/Sysinternals/ProcMon-for-Linux) 
- In terminal 2 : `./procmon -p <mypid>` *(specify -e to filter on a specific syscall)*

#### Testing with strace:
- In terminal 2: `strace -p <mypid> -C -f` *(specify -e to filter on a specific syscall)*

The `-C` will give you a summary of all the syscall observed at the end of the session adn `-f` trace child processes as they are created by currently traced processes

Executed commmands on terminal 1:

- **`touch test.txt`**:

![image](https://github.com/mthcht/backup/assets/75267080/944fe0ca-a3fd-4ba5-adcd-085422a4446d)

27 syscalls for a file creation, an explanation of some the syscalls:
  - `clone`: Creates a new child process. It may be part of managing multiple processes within the touch command.
  - `pselect6`: Waits for some event on a file descriptor. This may relate to waiting for access to the file system to ensure that the file can be created or updated.
  - `read`: Reads data from file descriptors. It might be involved in reading configuration or other necessary data to handle the command.
  - **`write`: Writes data to file descriptors. This syscall might be involved in the actual writing or modification of file timestamps.**
  - `ioctl`: Controls device parameters. It's a general-purpose I/O control operation and can be used for various purposes, including file handling.
  - `rt_sigaction`: Signal handling. This syscall is used to handle different signals within the program execution, not specifically related to file creation but more to the execution of the command itself.
  - `rt_sigprocmask`: Manipulates signal masks, often used to block or unblock signals. Again, more related to the overall program execution.
  - `pipe`: Creates a unidirectional data channel that can be used for inter-process communication. May not be directly related to the file creation but is a part of handling the process.
  - `close`: Closes file descriptors, related to cleaning up after the file operations are done.
  - `stat`: Retrieves information about the file, such as size, type, and permissions. This may be used to determine whether the file exists or if its timestamp needs to be updated.
  - **`openat`: Opens a file at a specific path. This syscall is likely part of the process of creating or accessing the file to update its timestamp.**

**relevant syscall for file creation**: **`write`** + **`openat`**

- **`echo 123 > test.txt`**:

![image](https://github.com/mthcht/backup/assets/75267080/f7566508-d1e5-4d60-a56d-c81f858ad04c)

11 syscalls for adding content to a file with bash, let's verify each of them:
  - `dup2`: Duplicates a file descriptor, making the old and new descriptors interchangeable. This is often used for redirecting standard input/output, such as when implementing shell redirection.
  - **`write`: Writes data to a file descriptor. If you're creating or modifying a file, this syscall would be responsible for writing the actual data to the file (but it depends how the file was created and on the system OS/kernel version, we will see this later)**
  - **`openat`: This is a modern replacement for the open syscall that allows opening files relative to a directory file descriptor. It's used to open a file for reading or writing**
  - `rt_sigaction`: Changes the action taken by a process upon receipt of a specific signal. It's typically used to set up custom signal handling or to block or unblock certain signals during execution.
  - `pselect6`: Monitors multiple file descriptors to see if they are ready for reading, writing, or have an error condition pending. It might be used for handling multiple input or output streams.
  - `ioctl`: Stands for input/output control and is used to manipulate the underlying device parameters of filesystem objects.
  - `fcntl`: This is used for file control, like getting or setting file attributes, and it provides more detailed control over descriptors.
  - `rt_sigprocmask`: Used to block certain signals from being delivered to the current thread. It's useful for ensuring that certain parts of the code are not interrupted by specific signals.
  - `close`: Closes file descriptors, which is a necessary step after a file has been read or written to.
  - `stat`: Retrieves information about the file, like checking if the file exists, its size, permissions, etc.
  - `read`: Reads data from a file descriptor. In the context of a file manipulation operation, this could be used to read data from a file to be processed or copied elsewhere.

**relevant syscall for file modification**: **`write`** + **`openat`**
 
- **`rm -rf test.txt`**:

![image](https://github.com/mthcht/backup/assets/75267080/c3ea3e75-f49d-4fd1-988c-4d33750025f6)

29 syscalls for deleting a file with rm, below an explication for some of them:
  - `clone`: Similar to the previous command, this syscall is used for process creation. In the context of rm, it may be used to handle the recursion for the -r flag.
  - `pselect6`: Waits for an event on a file descriptor. It might be used to wait for access to the file system or specific file operations.
  - `read`: Reads data from file descriptors. In the context of rm, it might read necessary data or configuration.
  - `write`: Writes data to file descriptors. It might be used for logging or handling errors here.
  - `ioctl`: Controls device parameters. It might be used for various file handling purposes.
  - `rt_sigprocmask`: Manipulates signal masks. This syscall is more related to overall command execution rather than file deletion.
  - `rt_sigaction`: Signal handling, also not specific to file deletion but more related to the execution of the command itself.
  - `pipe`: Creates a data channel for inter-process communication.
  - `close`: Closes file descriptors, related to cleaning up after file operations are done.
  - `stat, lstat`: Retrieves file statistics. These calls may be used to check the existence of the file or its type before deletion.
  - `openat`: Opens a file at a specific path. This syscall may be part of the process of accessing the file before deletion.
  - **`unlinkat`: This syscall is the key to file deletion. It removes a name from the filesystem, effectively deleting the file.**

**relevant syscall for file deletion**: **`unlinkat`**

*note that without the `-f` argument of my strace command i wouldn't be able to see the `unlinkat` syscall*

- **`nano test.txt`** - editing test.txt with nano, adding data and saving the file:
![image](https://github.com/mthcht/backup/assets/75267080/f8cc11a0-f623-4f98-9b5f-4bdd98c98a41)

39 syscalls for a file content modification with nano, below an explication for some of them: 
  - **`openat`: This system call is used to open a file (in this case, test.txt). The openat calls may also include opening various configuration or shared library files necessary for the operation of the text editor nano.**
  - `read`: Reading from a file or other resources. In the context of a text editor, it is used to read the content of the file you are editing, as well as possibly reading configuration files or other resources needed by the editor.
  - **`write`: Writing to a file or other resources. In the context of a text editor like nano, this would be used to write the changes to the file. It's also used to write data to the terminal, updating what's displayed as you edit the file.**
  - `stat`: This system call retrieves information about the file (like permissions, size, etc.). It could be used to check properties of the file being edited, as well as other files that nano interacts with.
  - `mmap`: Memory mapping files or devices into the application's address space. This might be used to map the file into memory for more efficient access, or for other memory-related purposes within the editor.
  - **`lseek`: This system call changes the file offset of an open file descriptor, allowing the system to access different parts of the file. It is used to navigate around the file as you edit it.**
  - `ioctl`: This is a device control system call. In the context of a text editor, it might be used to control the terminal, such as querying the size of the window, setting non-blocking mode, etc.
  - `close`: This is used to close a file descriptor. In this case, it would be used to close the file after editing.
  - **`unlink`: This system call deletes a file. It is part of the process of saving changes`: a common pattern with vim or nano is to write the new file to a temporary location, then delete the old file and rename the new one to the correct location.**
  - `clone`: This is used to create a child process. Nano might use this as part of its internal handling of tasks such as auto-saving.
  - `access`: This system call checks the user's permissions for a file. Nano might use this to check if you have permission to write to the file you are editing, or to other files it needs to access.
  - `fcntl`: This syscall is used to perform various operations on file descriptors. It might be used to change the properties of the file or other resources nano is working with.
  - `getdents64`: This system call retrieves directory entries. It could be used as part of file browsing within the editor.

**relevant syscall for file deletion**: **`unlink`** (we can see now looking at our previous command `rm` that depending on the way a file is deleted it can be unlink or unlinkat)

**relevant syscall for file modification**: **`lseek` + `openat` + `write`**

*fyi with `vim test.txt` (adding content and saving), we get a similar result with some additional interresting syscall but nothing relevant for our use case*

- **`chmod a-w test.txt`** (permission modification: removing write access for test.txt)
![image](https://github.com/mthcht/backup/assets/75267080/10824617-3326-48aa-b5bc-32735acb62f4)

27 syscalls for a permission modification, the interresting one:
  - **`fchmodat`: This is a system call used to change the permissions (or mode) of a file. In the context of the chmod command, this is the system call that's doing the actual work of changing the permissions on test.txt.**

**relevant syscall for file permission change**:**`fchmodat`**

- **`chown mthcht:mthcht test.txt`** (owner of the file test.txt changed)
![image](https://github.com/mthcht/backup/assets/75267080/8a27f783-cced-418a-9a21-0f5ef88d9f96)

37 syscalls for changing the owner of a file, the interresting one:
  - **`fchownat`: This is a system call that changes the ownership of a file. In the context of the chown command, this system call is doing the actual work of changing the ownership of test.txt to the specified user and group (in this case, "mthcht:mthcht").**

**relevant syscall for file owner change**:**`fchownat`**

### SYSCALLS RESUME
Relevant Syscalls for Specific File Operations (after our tests)

Creation of a file: 
  - `open` or `openat` with `O_CREAT` flag: Creates or opens a file. (we will see how with auditd logs)
  - `write`

Modification of a file (content is added or removed):
  - `open` or `openat` with `O_WRONLY` or `O_RDWR` flag: Opens the file with write access. (we will see how with auditd logs)
  - `write`
  - `lseek`

File opened with write access but nothing is modified:
  - `open` or `openat` with `O_WRONLY` or `O_RDWR` flag: Opens the file with write access.
*The traces left by openning a file with write access and actually modifying content are the same (without write) so we must rely on `write` to actually make sure a file has been modified.*

Deletion of a file:
  - `unlink` or `unlinkat`: Removes the directory entry for the file, leading to its deletion if no more hard links exist.

File permissions changes:
  - `fchmod` or `fchmodat`

File owner changes:
  - `fchown` or `fchownat`

### AUDITD Configuration
Let's start with adding the following configuration in our .rules files for auditd
`-a always,exit -F dir=/root -F arch=b64 -S writev -S open -S openat -S write -S lseek -S unlink -S unlinkat -S fchown -S fchownat -S fchmod -S fchmodat -F success=1 -k files_ops_root`

This rule contains all the possible syscalls we can get for file operations

Explanation of the rule:
- `-a always,exit`: Ensures the rule is always applied at the exit of a syscall.
- `-F dir=/root`: Focuses on the /root directory.
- `-F perm=w`: Targets only write permissions, which includes modifications.
- `-S `: Specify all the syscall we want to monitor for file operations
- `-F success=1`: Filters only successful calls to minimize noise from failed attempts.
- `-k file_modification_root`: Assigns a key for easy identification of the records.

 This should help us identifying file operations within the root directory.

- `sudo systemctl restart auditd`
In terminal 1 for the test:
- `sudo auditctl -a always,exit -F dir=/root -F perm=w -S open,openat,write,lseek,unlink,unlinkat,fchown,fchownat,fchmod,fchmodat -F success=1 -k files_ops_root`
In terminal 2 executing the following commands:
  - `touch test_auditd.txt`
  - `echo 123 > test_auditd.txt`
  - `rm -rf  test_auditd.txt`

### AUDITD LOGS

*you can execute `ausearch -k files_ops_root` (command to see if the rule was triggered as expected in the logs) or just grep/tail the log file auditd.log to see what happened* 

#### File creation: `touch test_creation.txt`, generated these logs in auditd.log:
```yaml
type=SYSCALL msg=audit(1691714604.324:6628017): arch=c000003e syscall=257 success=yes exit=3 a0=ffffff9c a1=7fffd50b122c a2=941 a3=1b6 items=2 ppid=6434 pid=23942 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts4 ses=3 comm="touch" exe="/usr/bin/touch" subj=unconfined key="files_ops_root"
type=CWD msg=audit(1691714604.324:6628017): cwd="/root"
type=PATH msg=audit(1691714604.324:6628017): item=0 name="/root" inode=654081 dev=08:01 mode=040700 ouid=0 ogid=0 rdev=00:00 nametype=PARENT cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0
type=PATH msg=audit(1691714604.324:6628017): item=1 name="test_creation.txt" inode=655075 dev=08:01 mode=0100644 ouid=0 ogid=0 rdev=00:00 nametype=CREATE cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0
type=PROCTITLE msg=audit(1691714604.324:6628017): proctitle=746F75636800746573745F6372656174696F6E2E747874
```
We can see 5 logs with 4 different message types, let's verify the content of each message type:

#### **type=SYSCALL**: This line shows the details of the system call

`type=SYSCALL msg=audit(1691714604.324:6628017): arch=c000003e syscall=257 success=yes exit=3 a0=ffffff9c a1=7fffd50b122c a2=941 a3=1b6 items=2 ppid=6434 pid=23942 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts4 ses=3 comm="touch" exe="/usr/bin/touch" subj=unconfined key="files_ops_root"`

- arch=`c000003e`: Architecture of the system call, corresponding to x86_64 here.
- syscall=`257`: The system call number, which corresponds to the **openat** syscall on x86_64.
- success=`yes`: Indicates that the syscall succeeded.
- ppid=`6434`: Parent process ID.
- pid=`23942`: Process ID of the command.
- auid=`1000`: Audit user ID.
- uid=`0`, gid=`0`: User and group IDs (**user root in this case**).

you can retrive the user name corresponding to an uid with the command `getent passwd <uid>` (add `| cut -d':' -f1` to only get the user name)

![image](https://github.com/mthcht/backup/assets/75267080/585415d2-9508-4ad5-a8db-262267106aa8)

- exe=`"/usr/bin/touch"`: The executable that initiated the syscall.
- key=`"files_ops_root"`: The key associated with the audit rule we created earlier.

This openat syscall has the following arguments:
- a0=`ffffff9c`: This argument is typically the file descriptor of the directory in which the file resides or special values like AT_FDCWD, which refers to the current working directory. **ffffff9c** is the hexadecimal representation of **-100**, which is **AT_FDCWD** on most systems, meaning the path in the next argument is relative to the current working directory.
- a1=`7fffd50b122c`: This is a memory address pointing to the path of the file to be opened, in this case, test_creation.txt.
- a2=`941`: This argument specifies the file's opening mode and flags. It is usually represented as a combination of different constants like O_CREAT, O_RDWR, O_APPEND, etc. The exact value 941 is a bitwise OR of different flags and modes.

The argument value `941` in hexadecimal corresponds to `0x3C1`, and we can interpret it by breaking it down into the corresponding flags used in the open syscall.

O_WRONLY: Write-only access. Its value is typically `0x01`.

O_CREAT: Create the file if it does not exist. Its value is typically `0x40`.

O_TRUNC: If the file already exists and is a regular file, and the open mode allows writing (i.e., is O_RDWR or O_WRONLY), it will be truncated to length 0. Its value is typically `0x200`.

O_CLOEXEC: Set the close-on-exec flag for the new file descriptor. This means that the file descriptor will be closed automatically when a new program is executed (e.g., after a fork and execve call). Its value is typically `0x800`.

summing these contents:
```
0x01 (O_WRONLY)
+ 0x40 (O_CREAT)
+ 0x200 (O_TRUNC)
+ 0x800 (O_CLOEXEC)
---------
0x3C1
```
But the actual values can vary depending on the specific OS and kernel version, it will be challenging to calculate every possible value of a2 when creating a file...

- a3=1b6: This argument typically represents the file's mode if it's being created (i.e., the permissions with which it should be created). The value 1b6 in hexadecimal corresponds to 0644 in octal, which represents the standard file permissions `-rw-r--r--`. This means that the owner has read and write permissions, while the group and others have read permissions (This is something we can use).


#### **type=CWD**: Current working directory from which the syscall was made = **/root**

`type=CWD msg=audit(1691714604.324:6628017): cwd="/root"`

#### **type=PATH**: Information about the paths related to the syscall.

```
type=PATH msg=audit(1691714604.324:6628017): item=0 name="/root" inode=654081 dev=08:01 mode=040700 ouid=0 ogid=0 rdev=00:00 nametype=PARENT cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0
type=PATH msg=audit(1691714604.324:6628017): item=1 name="test_creation.txt" inode=655075 dev=08:01 mode=0100644 ouid=0 ogid=0 rdev=00:00 nametype=CREATE cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0
```

- item: The item number within a syscall event that this record describes. A syscall may have more than one PATH record, and the item numbers would be sequential starting from 0.
  - **item=0** name="/root": Information about the parent directory.
  - **item=1** name="test_creation.txt": Information about the file being created.
( name: The name or path of the file or directory object. This can be a relative or absolute path.
- mode=040700: This is the mode of the directory /root, where 04 represents the directory type, and 0700 represents permissions (read, write, execute for the owner, no permissions for others).
- mode=0100644: This is the mode of the file, where 01 represents a regular file, and 0644 represents permissions (read and write for the owner, read for the group and others).
- ouid=0, ogid=0: The owner and group IDs are both 0, meaning the root user.
- nametype=PARENT: The /root directory is the parent of the object being affected.
- **nametype=CREATE: The file test_creation.txt is being created.**

Now we have an interresting value `CREATE` for the nametype if the path related to our syscall, we should use this to identify file creation instead of the falgs of openat seen earlier.

**type=PROCTITLE**: The command-line arguments of the process, in hexadecimal. 

`type=PROCTITLE msg=audit(1691714604.324:6628017): proctitle=746F75636800746573745F6372656174696F6E2E747874`

- proctitle: 746F75636800746573745F6372656174696F6E2E747874 = `touch test_creation.txt`


Summary for File creation: 

At the end we are only relying on the syscall **openat** on our system and not **write** with the touch command, make sure to not only rely on **write** but also include open/openat in your auditd configuration.

#### File modification: `echo 'mthcht' > test_modification.txt`, generated these logs in auditd.log:

```
type=SYSCALL msg=audit(1691744760.894:6628234): arch=c000003e syscall=257 success=yes exit=3 a0=ffffff9c a1=56048c8a70d0 a2=241 a3=1b6 items=2 ppid=25290 pid=25291 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts4 ses=3 comm="bash" exe="/usr/bin/bash" subj=unconfined key="files_ops_root"
type=CWD msg=audit(1691744760.894:6628234): cwd="/root"
type=PATH msg=audit(1691744760.894:6628234): item=0 name="/root" inode=654081 dev=08:01 mode=040700 ouid=0 ogid=0 rdev=00:00 nametype=PARENT cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0
type=PATH msg=audit(1691744760.894:6628234): item=1 name="test_modification.txt" inode=655078 dev=08:01 mode=0100644 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0
type=PROCTITLE msg=audit(1691744760.894:6628234): proctitle="bash"
```

Since we already explain most of the fields in the file creation part, for now on i will only keep the most important fields for each file operation...

**type=SYSCALL**:

`type=SYSCALL msg=audit(1691744760.894:6628234): arch=c000003e syscall=257 success=yes exit=3 a0=ffffff9c a1=56048c8a70d0 a2=241 a3=1b6 items=2 ppid=25290 pid=25291 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts4 ses=3 comm="bash" exe="/usr/bin/bash" subj=unconfined key="files_ops_root"`

- syscall = 257 (openat)
- comm="bash", exe="/usr/bin/bash": Command and executable path of the process that triggered the syscall.
SYSCALL arguments:
- a1=56048c8a70d0: Pointer to the pathname string (test_modification.txt).
- a2=241: Second argument to the syscall, which are the flags passed to openat. 241 indicates flags like O_WRONLY (write-only) and O_TRUNC (truncate file to zero length).
- a3=1b6: Third argument, the file mode, specifying the permissions if a new file is created.
- cwd="/root": Current working directory where the command was executed.

**type=cwd**: 

`type=CWD msg=audit(1691744760.894:6628234): cwd="/root"`

- cwd="/root": Current working directory from which the syscall was made

**type=PROCTITLE**:

`type=PROCTITLE msg=audit(1691744760.894:6628234): proctitle="bash"`

- we only have the executable name here for a file modification and not the full commandline as we saw in the file creation (the commandline can be retrieve anyway by monitoring `execve` in the auditd configuration file (but not our use case for FIM) 


**type=PATH**:

`type=PATH msg=audit(1691744760.894:6628234): item=0 name="/root" inode=654081 dev=08:01 mode=040700 ouid=0 ogid=0 rdev=00:00 nametype=PARENT cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0`
`type=PATH msg=audit(1691744760.894:6628234): item=1 name="test_modification.txt" inode=655078 dev=08:01 mode=0100644 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0`

- **item=0** name="/root": Information about the parent directory.
- **item=1** name="test_modification.txt": Information about the file being modified.
- nametype=NORMAL: This type specifies that the name in the path record is the primary object in question for the audit record. In the context of a file modification, identifying it through these logs can be a bit indirect.

In summary here's what you might consider for **detecting file modifications**:
- You see the syscall=257 (openat) with a success, and the flags a2=241, which includes O_WRONLY (write-only) and O_TRUNC (truncate file to zero length). This combination could indicate that the file was opened with the intent to be modified.
- You know the path of the file being modified (name="test_modification.txt"), and you can see that it's opened with write permissions. (mode=0100644)
- If you were to combine this with other logs such as a write syscall to the same file descriptor, it would give you a stronger indication of a file modification but we don't see it with our test.

This is problematic because we cannot be sure that the file has been modified with our logs, **we only know if the file has been opened with write permissions** and sometimes that's enough for correlation with the commandline, but if you want to go further and make sure that a file has been modified you will have to get logs of **file hash modifications** and there is nothing included with auditd to do this, you can do a custom script to log file hash of given directories frequently and correlate the openat syscall with write permissions event with the file hash modifications events from your script.

I made a script for the example, you can improve it/modify it for your need (simple python script to log hashes of all the files in given directories frequently) : https://github.com/mthcht/Purpleteam/tree/main/Logging/auditd

set the configuration in the .conf file:

![image](https://github.com/mthcht/backup/assets/75267080/295b2154-8c8e-4080-a235-8d843e5dd9ea)

execute the script: `python logging_files_hashes.py logging_files_hashes.conf` (for the test)

result in the .log file:

log_level=INFO: `_time,epoch_time,log_level,file_path,file_hash`

log_level=DEBUG: `_time,epoch_time,log_level,file_path,message` OR `_time,epoch_time,log_level,message`

![image](https://github.com/mthcht/backup/assets/75267080/b2a460b9-d43c-4d76-b55d-9fee1be45f5e)


FYI the solution OSSEC https://github.com/ossec/ossec-hids include a syscheck binary to do this (also alerting on file hash changes) allowing us to correlate the events of file access and file modifications (OSSEC is an alternative to auditd)

#### File deletion: `rm -rf test_deletion.txt`, generated these logs in auditd.log:
```
type=SYSCALL msg=audit(1691747463.379:6628264): arch=c000003e syscall=263 success=yes exit=0 a0=ffffff9c a1=561b659c14d0 a2=0 a3=fffffffffffffb8c items=2 ppid=25291 pid=25450 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts4 ses=3 comm="rm" exe="/usr/bin/rm" subj=unconfined key="files_ops_root"
type=CWD msg=audit(1691747463.379:6628264): cwd="/root"
type=PATH msg=audit(1691747463.379:6628264): item=0 name="/root" inode=654081 dev=08:01 mode=040700 ouid=0 ogid=0 rdev=00:00 nametype=PARENT cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0
type=PATH msg=audit(1691747463.379:6628264): item=1 name="test_deletion.txt" inode=655079 dev=08:01 mode=0100644 ouid=0 ogid=0 rdev=00:00 nametype=DELETE cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0
type=PROCTITLE msg=audit(1691747463.379:6628264): proctitle=726D002D69002D726600746573745F64656C6574696F6E2E747874
```

**type=SYSCALL**:
- syscall=263: This corresponds to the `unlinkat` system call, which is used to delete a file. (we saw the same syscall in our test with strace at the beggining)
- success=yes: The system call was successful.
exit=0: The return value of the syscall, indicating success (no error).
comm="rm" and exe="/usr/bin/rm": These show that the command was executed by the rm binary.

**type=PATH** item0:
- name="/root": The directory containing the file.
- nametype=PARENT: This type specifies that the object was a parent of the primary object in question.

**type=PATH** item1:
- **nametype=DELETE**: This type specifies that the object was deleted. This is a clear indication of the deletion operation.
- name="test_deletion.txt": The name of the file being deleted.

**type=PROCTITLE**:
- proctitle=`726D002D69002D726600746573745F64656C6574696F6E2E747874`: This field provides the command-line arguments in hexadecimal. It corresponds to the `rm -rf test_deletion.txt` command.

Summary for this file deletion: 

Syscall 263 (unlinkat - same as our initial test with syscalls) and the field nametype with the value DELETE in the PATH message type clearly indicates that this was a deletion operation and we can rely on this to identify file deletions.

  
#### **LOG Correlation**:
Each operation generate at least 5 type of message ( 5 different lines of logs), everything is separated in different log and we need to reconstruct the log to understand what happened and the only field that can be used for correlation is the field `msg`:
- msg=audit(<timestamp>:<message_identifier>)

When you collect the logs on your SIEM, you can aggregate the auditd logs by the timestamp or the message_identifier (sometimes correlating with the timestamp is easier to read and allow the correlation of multiple different sessions events), for example on Splunk you can use the command `|transaction <timestamp>` or `| transaction <message_identifier>` this will group the raw logs in one raw log with the same <timestamp> or <message_identifier>. doc : https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/Transaction   

/!\ this is a very consumming search and i do not recommand using it if you care about performances 

For dashboards and detection rules, you can get some important fields value by creating new fields before your stats command and get the most of the important fields like you would with a transaction command: 

```
  | eval tmp_action_list=if(syscall IN (1,257,87,263) AND status="success","yes","no"), _details=syscall.":".status 
  | eval objtype=coalesce(objtype, "N/A")
  | eval modified=if(objtype IN ("CREATE","DELETE"),"yes","no")
... your stats command with your eval fields in values()...
... mvexpand modified 
  | search modified=yes
```

*replace with your own field names*

If you don't have a SIEM or the performance to do that, you may want to change the logs format before ingesting them in your SIEM, here is an example script i made just for syscall 257 (add your own mapping, this is just an quick example): https://github.com/mthcht/Purpleteam/blob/main/Logging/auditd/log_format/example_test_format_log.py

![image](https://github.com/mthcht/backup/assets/75267080/01a7dbf4-16b6-4107-aea8-299109ec050d)

#### Final configuration:

After all our tests, the relevant auditd rules for FIM will contain all the syscall we observed in our initial test even if they were not called with our commands and system, they could be called in other situations:

`-a always,exit -F dir=/root -F arch=b64 -S writev -S open -S openat -S write -S lseek -S unlink -S unlinkat -S fchown -S fchownat -S fchmod -S fchmodat -F success=1 -k files_ops_root`

if you want to also monitor failed access, remove `-F success=1`, add a line in your auditd rule for each path you want to monitor for file operations, change `dir=<mypath>` and rename the key field (`-k <mykeyfield>`) with the path name you choosed, this way you can easily filter in your logs the operation made.


#### Conclusion

The integration of auditd as a complete solution for File Integrity Monitoring is possible but is not easy as it requieres a lot of effort:

The separation of Information Across Logs for correlation is problematic, the information about a single event spread across multiple log entries. Understanding a single event require correlating information from different log lines. The separation of syscall data, path information, command execution details, and other attributes necessite a sophistiate log parsing process. If you want to build meaningful alerts or dashboards, it requires a comprehensive understanding of how different parts of an event are logged. The integration and parsing must be properly configured (uses of scripts or consumming searches on the SIEM).

I hope this blog helped a bit, happy hunting !
