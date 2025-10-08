#! /usr/bin/env python3

# import os
# import subprocess
# import argparse
# import json
# from pathlib import PosixPath, PurePosixPath

# import podman
# from rich import progress

import tomllib
import platform
import datetime
import koji
import requests


def main():
            
    # class Packages():
    #     def __init__(self, dictionary):
    #         for key, value in dictionary.items():
    #             setattr(self, key, value)

    # with open(args.config_file, "rb") as file:
    with open("koji-download-build.toml", "rb") as file:
        config_dict = tomllib.load(file)
    print(f"\n config_dict: {type(config_dict)} {config_dict}\n")

    # packages = ["bootc", "ostree"]
    # packages = config_dict["packages"]["packages"]
    packages = config_dict["packages"]
    print(f"\n packages: {type(packages)} {packages}\n")
    
    os_release = platform.freedesktop_os_release()
    for key, value in os_release.items():
        print(f" {key}: {value}")
        
    arch = platform.machine()
    list_builds_pattern = f"*fc{os_release["VERSION_ID"]}*"
    # four_months_ago = datetime.datetime.now().date() - datetime.timedelta(days=123)
    four_months_ago = datetime.datetime.now() - datetime.timedelta(days=123)
    # print(f"\n four_months_ago: {type(four_months_ago)} {four_months_ago}\n")
    # four_months_ago_timestamp = four_months_ago.replace(tzinfo=datetime.timezone.utc).timestamp()
    # print(f"\n four_months_ago_timestamp: {type(four_months_ago_timestamp)} {four_months_ago_timestamp}\n")

    session = koji.ClientSession("https://koji.fedoraproject.org/kojihub")
    
    for package in packages:
        latest_build = session.listBuilds(packageID=package, completeAfter=str(four_months_ago), pattern=list_builds_pattern)[-1]
        # print(f"\n latest_build: {type(latest_build)} {latest_build}\n")
        print(f"\n four_months_ago: {type(four_months_ago)} {four_months_ago}")
        print("\n Latest Build:")
        print(f" build_id: {latest_build["build_id"]}")
        print(f" completion_time: {latest_build["completion_time"]}")
        # print(f" completion_ts: {latest_build["completion_ts"]}")
        print(f" draft: {latest_build["draft"]}")
        print(f" name: {latest_build["name"]}")
        print(f" nvr: {latest_build["nvr"]}")
        print(f" package_name: {latest_build["package_name"]}")
        print(f" release: {latest_build["release"]}")
        print(f" state: {latest_build["state"]}")
        print(f" version: {latest_build["version"]}\n")

        rpms = []
        if len(arch) == 0:
            arch = None
        # all_rpms = session.listRPMs(buildID=latest_build["id"], arch=arch)
        all_rpms = session.listRPMs(buildID=latest_build["build_id"], arches=arch)
        if not all_rpms:
            if arch:
                print("No %s packages available for %s" %
                        (" or ", koji.buildLabel(latest_build)))
            else:
                print("No packages available for %s" % koji.buildLabel(latest_build))
        
        # Compile the path to the directory where a build belongs
        build_path = f"https://kojipkgs.fedoraproject.org/packages/{latest_build["name"]}/{latest_build["version"]}/{latest_build["release"]}"
        # print(f"\n build_path: {type(build_path)} {build_path}")
        
        for rpm in all_rpms:
            
            # print(rpm)

            # Compile the path (relative to build_path) where an rpm belongs
            rpm_path = f"{arch}/{rpm["name"]}-{rpm["version"]}-{rpm["release"]}.{arch}.rpm"
            # print(f" rpm_path: {type(rpm_path)} {rpm_path}")
            
            download_url = f"{build_path}/{rpm_path}"
            # print(f"\n download_url: {type(download_url)} {download_url}\n")

            rpm["download_url"] = download_url
            # print(f"\n rpm[\"download_url\"]: {type(rpm["download_url"])} {rpm["download_url"]}\n")

            rpms.append(rpm)

        # print(f"\n rpms: {type(rpms)} {rpms}\n")
        
        for index, rpm_from_list in enumerate(rpms):
            # print(f"\n {index}. rpm_from_list[\"download_url\"]: {type(rpm_from_list["download_url"])} {rpm_from_list["download_url"]}\n")

            rpms_download_path = f"/tmp/rpms/{rpm_from_list["name"]}-{rpm_from_list["version"]}-{rpm_from_list["release"]}.{arch}.rpm"
            # print(f" \n {index}. rpms_download_path {rpms_download_path}")

            try:
                response = requests.get(rpm_from_list["download_url"], allow_redirects=True)
                response.raise_for_status()
                print(f" Downloading {rpms_download_path}")
                with open(rpms_download_path, "wb") as file:
                    file.write(response.content)
            except requests.RequestException as err:
                print(f" Request error: {err}")
            except IOError as err:
                print(f" File error: {err}")


if __name__ == "__main__":
    # https://docs.python.org/library/exceptions.html#SystemExit
    raise SystemExit(main())