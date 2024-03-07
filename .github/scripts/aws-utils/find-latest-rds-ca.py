#!/usr/bin/env python3

"""
Script: get_latest_rds_ca.py
Description: Retrieves the latest RDS CA (Certificate Authority) file from the AWS S3 bucket.
             Parses the XML file, filters relevant elements, and finds the file with the latest year in its name.
             Prints the result in the format: 'https://s3.amazonaws.com/rds-downloads/<latest_file_name>'.
"""

import requests
import xml.etree.ElementTree as ET
import re

# XML file URL
xml_url = "https://s3.amazonaws.com/rds-downloads/"

response = requests.get(xml_url)

# Check if the request is successful (status code 200)
if response.status_code == 200:
    # Retrieve XML content
    xml_data = response.content.decode('utf-8')

    # Parse XML
    root = ET.fromstring(xml_data)
    namespace = {'ns': 'http://s3.amazonaws.com/doc/2006-03-01/'}
    keys = root.findall(".//ns:Key", namespaces=namespace)

    # Filter elements starting with 'rds-ca-' and ending with '-root.pem' with a year in the middle
    rds_ca_elements = [key for key in keys if re.match(r'rds-ca-\d{4}-root\.pem', key.text)]

    # Retrieve the latest file year
    latest_file_year = max(int(re.search(r'rds-ca-(\d{4})-root\.pem', key.text).group(1)) for key in rds_ca_elements)

    print(f"{xml_url}rds-ca-{latest_file_year}-root.pem")
else:
    # Print error message with a different exit code
    print(f"Request failed. Status code: {response.status_code}")
    exit(12)
