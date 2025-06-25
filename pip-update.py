#!/usr/bin/python3
#
# Filename: pip-update.py
# Read requirements.{in,txt} and output the latest versions of the packages.
# Usage: ./pip-update.py requirements.in

import sys
import json
import urllib.request
from urllib.error import URLError, HTTPError

def get_latest_version(package_name):
    url = f"https://pypi.org/pypi/{package_name}/json"
    try:
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read().decode('utf-8'))
            return data['info']['version']
    except HTTPError as e:
        print(f"HTTP Error for {package_name}: {e.code} {e.reason}", file=sys.stderr)
    except URLError as e:
        print(f"URL Error for {package_name}: {e.reason}", file=sys.stderr)
    except Exception as e:
        print(f"Error fetching {package_name}: {e}", file=sys.stderr)
    return None

def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py requirements.in", file=sys.stderr)
        sys.exit(1)

    input_file = sys.argv[1]
    try:
        with open(input_file, 'r') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                package_name = line.split('==')[0].strip()
                latest_version = get_latest_version(package_name)
                if latest_version is not None:
                    print(f"{package_name}=={latest_version}")
                else:
                    print(f"Could not fetch version for {package_name}", file=sys.stderr)
    except FileNotFoundError:
        print(f"File not found: {input_file}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
