import ipaddress
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

NETWORKS = [
    "10.0.10.0/24",  # LAN
    "10.0.20.0/24",  # DMZ
    "10.0.99.0/24"   # MGMT
]

PING_TIMEOUT = 1

def ping(ip):
    try:
        result = subprocess.run(
            ["ping", "-c", "1", "-W", str(PING_TIMEOUT), str(ip)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        return result.returncode == 0
    except Exception:
        return False
    
def scan_network(network):
    print(f"Scanning {network} ...")
    reachable = []
    for ip in ipaddress.IPv4Network(network):
        if ping(ip):
            reachable.append(str(ip))
    return reachable

def scan_network_parallel(network):
    print(f"Scanning {network} ...")
    reachable = []
    
    with ThreadPoolExecutor(max_workers=100) as executor:
        futures = {executor.submit(ping, str(ip)): ip for ip in ipaddress.IPv4Network(network)}
        for future in futures:
            ip = futures[future]
            if future.result():
                reachable.append(str(ip))
    return reachable

def main():
    use_parallel = True
    for network in NETWORKS:
        if use_parallel:
            hosts = scan_network_parallel(network)
        else:
            hosts = scan_network(network)
        print(f"{network} reachable hosts ({len(hosts)}):")
        for host in hosts:
            print(f"{host}")
        print()

if __name__ == "__main__":
    main()


