#!/usr/bin/env python3

# Simple http client for use in docker health checks when curl is unavailable

import sys
import requests

def main():
    if len(sys.argv) != 2:
        print("Usage: curl.py <url>")
        sys.exit(1)

    url = str(sys.argv[1])
    try:
        response = requests.get(url)
        if 200 <= response.status_code < 300:
            print(f"Success: Status code {response.status_code}")
        else:
            print(f"Error: Received status code {response.status_code}")
            sys.exit(1)
    except Exception as e:
        print(f"Request failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
