import json
import os
import httpx
from insert_data import insert_data
import sys
import importlib

def get_filter():
    internal_api = "https://api.agmarknet.gov.in/v1/daily-price-arrival/filters"

    headers = {
            "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36",
            "Accept": "application/json",
        }


    with httpx.Client(timeout = 30.0) as client:
        response = client.get(internal_api,headers=headers)
        response.raise_for_status()
        data = response.json()
        if not data.get("status"):
            raise ValueError(f"API Error Response: {data.get('message')}")
    return data
            





def create_mapping():
    filter_data = get_filter()
    output_py_path = "Data_mapping.py"
    

    if not filter_data:
        print(f"Error: {filter_data} empty.")
        return
        
    # Extract cmdt_data
    cmdt_data = filter_data.get("data", {}).get("cmdt_data", [])
    if not cmdt_data:
        print("Error: 'cmdt_data' not found or empty in data.json.")
        return

    print(f"Found {len(cmdt_data)} commodities. Generating dictionary mapping...")
    
    # Create the dictionary mapping
    # Format: commodity = {"cmdt_name": [cmdt_id, cmdt_group_id]}
    commodity_mapping = {}
    for item in cmdt_data:
        name = item.get("cmdt_name")
        cmdt_id = item.get("cmdt_id")
        cmdt_group_id = item.get("cmdt_group_id")
        if name is not None:
            commodity_mapping[name] = [cmdt_id, cmdt_group_id]
        else:
            print(f"Skipping item with missing name: {item}")

    print(f"Writing mapping to {output_py_path}...")
    with open(output_py_path, "w", encoding="utf-8") as f:
        f.write("# Generated commodity mapping from data.json\n")
        f.write("Commodity = {\n")
        for key, value in commodity_mapping.items():
            # Using repr for key to correctly handle any quotes or special characters
            f.write(f"    {repr(key)}: {value},\n")
        f.write("}\n")
        
    print("Mapping successfully generated and written.")

    # 1. State Mapping
    state_mapping = {}
    print(f"Found {len(filter_data.get("data", {}).get("state_data", []))} states. Generating dictionary mapping...")

    for item in filter_data.get("data", {}).get("state_data", []):
        name = item.get("state_name")
        state_id = item.get("state_id")
        if name is not None and state_id != 100000:
            state_mapping[name] = state_id

    # 2. District Mapping
    district_mapping = {}
    print(f"Found {len(filter_data.get("data", {}).get("district_data", []))} districts. Generating dictionary mapping...")
    for item in filter_data.get("data", {}).get("district_data", []):
        dist_id = item.get("id")
        name = item.get("district_name")
        state_id = item.get("state_id")
        if dist_id is not None and dist_id != 100001:
            district_mapping[dist_id] = [name, state_id]

    # 3. Mandi Mapping
    mandi_mapping = {}
    print(f"Found {len(filter_data.get("data", {}).get("market_data", []))} mandis. Generating dictionary mapping...")
    for item in filter_data.get("data", {}).get("market_data", []):
        mkt_id = item.get("id")
        name = item.get("mkt_name")
        district_id = item.get("district_id")
        if mkt_id is not None and mkt_id != 100002:
            mandi_mapping[mkt_id] = [name, district_id]


    # 4. Variety Mapping
    # variety_data structure: [{"id": variety_id, "cmdt_id": [list of cmdt_ids] or None, "variety_name": "..."}]
    # Output: {sequential_id: [variety_name, cmdt_id]}  — one row per commodity association
    Variert_new = {}
    seq_id = 1
    print(f"Found {len(filter_data.get("data", {}).get("variety_data", []))} varieties. Generating dictionary mapping...")
    for item in filter_data.get("data", {}).get("variety_data", []):
        variety_name = item.get("variety_name")
        cmdt_ids = item.get("cmdt_id")
        if not variety_name or not cmdt_ids:
            continue
        for cmdt_id in cmdt_ids:
            Variert_new[seq_id] = [variety_name, cmdt_id]
            seq_id += 1

    # 5. Grade Mapping
    # grade_data structure: [{"grade_id": ..., "grade_name": "...", "cmdt_id": [list] or None}]
    # Output: {sequential_id: [grade_name, cmdt_id]}  — one row per commodity association
    Grade_new = {}
    seq_id = 1
    print(f"Found {len(filter_data.get("data", {}).get("grade_data", []))} grades. Generating dictionary mapping...")
    for item in filter_data.get("data", {}).get("grade_data", []):
        grade_name = item.get("grade_name")
        cmdt_ids = item.get("cmdt_id")
        if not grade_name or not cmdt_ids:
            continue
        for cmdt_id in cmdt_ids:
            Grade_new[seq_id] = [grade_name, cmdt_id]
            seq_id += 1


    

    # 6. cmdt_group Mapping
    cmdt_group_mapping = {}
    print(f"Found {len(filter_data.get("data", {}).get("cmdt_group_data", []))} cmdt groups. Generating dictionary mapping...")
    for item in filter_data.get("data", {}).get("cmdt_group_data", []):
        group_id = item.get("id")
        name = item.get("cmdt_grp_name")
        if name is not None:
            cmdt_group_mapping[name] = group_id

    print(f"Appending additional mappings to {output_py_path}...")
    with open(output_py_path, "a", encoding="utf-8") as f:
        # Write State
        f.write("\nState = {\n")
        for key, value in state_mapping.items():
            f.write(f"    {repr(key)}: {value},\n")
        f.write("}\n")

        # Write District
        f.write("\nDistrict = {\n")
        for key, value in district_mapping.items():
            f.write(f"    {key}: {repr(value)},\n")
        f.write("}\n")

        # Write Mandi
        f.write("\nMandi = {\n")
        for key, value in mandi_mapping.items():
            f.write(f"    {key}: {repr(value)},\n")
        f.write("}\n")

        # Write Variety
        f.write("\nVariety = {\n")
        for key, value in Variert_new.items():
            f.write(f"    {repr(key)}: {value},\n")
        f.write("}\n")        

        # Write Grade
        f.write("\nGrade = {\n")
        for key, value in Grade_new.items():
            f.write(f"    {repr(key)}: {value},\n")
        f.write("}\n")  

        # Write cmdt_group
        f.write("\nCommodityGroup = {\n")
        for key, value in cmdt_group_mapping.items():
            f.write(f"    {repr(key)}: {value},\n")
        f.write("}\n")

    print("All mappings appended successfully.")

    insert_data()

if __name__ == "__main__":
    create_mapping()
