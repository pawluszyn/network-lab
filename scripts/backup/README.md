# Lab Backup Script

This script is a simple backup tool designed for a small lab environment.
It connects to multiple machines over SSH and pulls selected directories to a central backup server using `rsync`.

The script creates **daily snapshots** and keeps the last three versions of each backup.

---

## How it works

The backup server reads a configuration file that lists hosts and directories to back up.

For each host the script:

1. Connects over SSH
2. Pulls selected directories using `rsync`
3. Stores them in `/backup/<hostname>/`
4. Rotates backups:

   * `daily.0` – newest snapshot
   * `daily.1` – previous snapshot
   * `daily.2` – older snapshot

The script uses `rsync --link-dest`, so unchanged files are **hard-linked** between snapshots.
This means incremental backups use **very little additional disk space**.

---

## Requirements

The backup server must have:

* `bash`
* `rsync`
* SSH access to all hosts

Each remote machine must allow the backup user to run `rsync` with sudo:

```
devops ALL=(ALL) NOPASSWD:/usr/bin/rsync
```

SSH key authentication should be configured so backups can run without passwords.

---

## Configuration

Hosts and directories are defined in:

```
/etc/lab_backup.conf
```

Example:

```
jenkins-server 10.0.99.4 /etc /var/lib/jenkins
desktop1 10.0.10.5 /home/devops
desktop2 10.0.10.3 /home/devops
web1 10.0.20.2 /etc/nginx /var/www
web2 10.0.20.3 /etc/nginx /var/www
```

Format:

```
HOSTNAME IP DIRECTORY1 DIRECTORY2 DIRECTORY3
```

---

## Backup Location

All backups are stored in:

```
/backup
```

Example structure:

```
/backup
 ├── jenkins-server
 │   ├── daily.0
 │   ├── daily.1
 │   └── daily.2
 ├── desktop1
 └── web1
```

---

## Running the script

Manual run:

```
sudo /usr/local/bin/lab_backup.sh
```

---

## Automated backups

Add a cron job on the backup server:

```
crontab -e
```

Example (runs daily at 02:00):

```
0 2 * * * /usr/local/bin/lab_backup.sh
```

---

## Notes

* The script is **pull-based**, meaning the backup server initiates all backups.
* The first run creates a full backup.
* Subsequent runs are incremental thanks to `rsync` hardlink snapshots.
* Designed for **lab environments or small infrastructures**.

