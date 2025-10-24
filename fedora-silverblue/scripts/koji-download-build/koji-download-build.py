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
from pathlib import PurePosixPath, PosixPath
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
    for key, value in config_dict.items():
        print(f" {key}: {value}")

    # packages = ["bootc", "ostree"]
    # packages = config_dict["packages"]["packages"]
    # packages = config_dict["packages"]
    packages = list(config_dict)
    print(f"\n packages: {type(packages)} {packages}\n")
    
    os_release = platform.freedesktop_os_release()
    arch = platform.machine()

    rpms_download_dir = PurePosixPath("/tmp/rpms")
    # print(f"\n rpms_download_dir: {type(rpms_download_dir)} {rpms_download_dir}\n")
    try:
        PosixPath.mkdir(rpms_download_dir)
    except FileExistsError as err:
        print(f"\n Directory already exists: {err}\n")

    session = koji.ClientSession("https://koji.fedoraproject.org/kojihub")
    
    for package in packages:

        latest_build = session.getLatestBuilds("f43-updates-testing", package=package, draft=False)[-1]
        
        rpms = []
        if len(arch) == 0:
            arch = None
        # all_rpms = session.listRPMs(buildID=latest_build["id"], arch=arch)
        # all_rpms = session.listRPMs(buildID=latest_build["build_id"], arches=arch)
        all_rpms = session.listRPMs(buildID=latest_build["build_id"])
        if not all_rpms:
            if arch:
                print("No %s packages available for %s" %
                        (" or ", koji.buildLabel(latest_build)))
            else:
                print("No packages available for %s" % koji.buildLabel(latest_build))
        
        # Compile the path to the directory where a build belongs
        build_path = f"https://kojipkgs.fedoraproject.org/packages/{latest_build["name"]}/{latest_build["version"]}/{latest_build["release"]}"
        # print(f"\n build_path: {type(build_path)} {build_path}")
        
        def is_debug(name):
            """Determines if an rpm is a debug rpm, based on name"""
            return (name.endswith("-debuginfo") 
                or name.endswith("-debugsource") 
                or "-debuginfo-" in name)
        
        for rpm in all_rpms:
            # if rpm["arch"] == "noarch" or rpm["arch"] == arch:
            if rpm["arch"] == "src" or rpm["arch"] == arch:
                # print(f"{rpm}\n")

                # Compile the path (relative to build_path) where an rpm belongs
                # rpm_path = f"{arch}/{rpm["name"]}-{rpm["version"]}-{rpm["release"]}.{arch}.rpm"
                rpm_path = f"{rpm["arch"]}/{rpm["name"]}-{rpm["version"]}-{rpm["release"]}.{rpm["arch"]}.rpm"
                # print(f" rpm_path: {type(rpm_path)} {rpm_path}")
                
                download_url = f"{build_path}/{rpm_path}"
                # print(f"\n download_url: {type(download_url)} {download_url}\n")

                rpm["download_url"] = download_url
                # print(f"\n rpm[\"download_url\"]: {type(rpm["download_url"])} {rpm["download_url"]}\n")

                if is_debug(rpm["name"]):
                    continue
                rpms.append(rpm)

        # print(f"\n rpms: {type(rpms)} {rpms}\n")
        
        for index, rpm_from_list in enumerate(rpms):
            # print(f"\n {index}. rpm_from_list[\"download_url\"]: {type(rpm_from_list["download_url"])} {rpm_from_list["download_url"]}\n")

            # rpm_full_name = f"{rpm_from_list["name"]}-{rpm_from_list["version"]}-{rpm_from_list["release"]}.{arch}.rpm"
            rpm_full_name = f"{rpm_from_list["name"]}-{rpm_from_list["version"]}-{rpm_from_list["release"]}.{rpm_from_list["arch"]}.rpm"
            rpms_download_path = f"{rpms_download_dir}/{rpm_full_name}"
            print(f" \n {index}. rpms_download_path {rpms_download_path}")

            try:
                response = requests.get(rpm_from_list["download_url"], allow_redirects=True)
                response.raise_for_status()
                # print(f" Downloading {rpms_download_path}")
                print(f" Downloading {rpm_full_name}")
                with open(rpms_download_path, "wb") as file:
                    file.write(response.content)
            except requests.RequestException as err:
                print(f" Request error: {err}")
            except IOError as err:
                print(f" File error: {err}")


if __name__ == "__main__":
    # https://docs.python.org/library/exceptions.html#SystemExit
    raise SystemExit(main())