import subprocess
import sys
import os
os.chdir(os.path.dirname(os.path.abspath(__file__)))
subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])

import argparse
import filecmp
import json
import shutil
from pathlib import Path
from zipfile import ZipFile

import cursepy
from cursepy.classes.base import CurseFile
from cursepy.handlers.metacf import MetaCFAddonFile


class ProgramArgs:
    minecraft_server_path: Path
    minecraftinstance_json_path: Path
    curseforge_core_api_key: str
    download_directory: Path

    def __init__(self):
        pass

    @staticmethod
    def parse_args() -> "ProgramArgs":
        parser = argparse.ArgumentParser(
            description="Builds/updates a server modpack from a CurseForge client modpack.")
        parser.add_argument("--minecraft-server-path", type=Path, required=True,
                            dest="minecraft_server_path",
                            help="Path to the Minecraft server installation")
        parser.add_argument("--minecraftinstance-json-path", type=Path, required=True,
                            dest="minecraftinstance_json_path",
                            help="Path to the new \"minecraftinstance.json\" file from created by the CurseForge "
                                 "launcher")
        parser.add_argument("--curseforge-core-api-key", type=str,
                            dest="curseforge_core_api_key",
                            help="API key for CurseForge Core",
                            default=os.environ["CURSEFORGE_API_KEY"])
        parser.add_argument("--download-directory", type=Path, required=True,
                            dest="download_directory",
                            help="Local path to download mods to for building")

        program_args = ProgramArgs()
        parser.parse_args(namespace=program_args)
        return program_args


def set_addon_file_formatter():
    default_formatter = MetaCFAddonFile.format

    def addon_file_formatter(_: MetaCFAddonFile, data: dict) -> CurseFile:
        build_curse_file = default_formatter(data)
        build_curse_file.server_pack_file_id = data["serverPackFileId"] if "serverPackFileId" in data else ""
        return build_curse_file

    MetaCFAddonFile.format = addon_file_formatter


def load_json_file(file_path: Path):
    with open(file_path) as file:
        return json.load(file)


def main():
    print("Beginning modpack update script...")
    args = ProgramArgs.parse_args()
    new_json_file_path = args.minecraftinstance_json_path
    old_json_file_path = args.minecraft_server_path.joinpath("minecraftinstance.json")
    modpack_zip_path = args.minecraft_server_path.joinpath("modpack.zip")

    if old_json_file_path.is_file() and filecmp.cmp(new_json_file_path, old_json_file_path):
        print("No changes detected, not updating")
        quit(0)

    if modpack_zip_path.is_file():
        print(f"Found modpack zip at {modpack_zip_path}")
        with ZipFile(modpack_zip_path) as modpack_zip:
            zip_files = [info.filename for info in modpack_zip.infolist() if not info.is_dir()]
            for zip_file in zip_files:
                server_file_path = args.minecraft_server_path.joinpath(Path(zip_file))
                print(f"Removing {zip_file} at {server_file_path}")
                server_file_path.unlink(missing_ok=True)

        print(f"Removing {modpack_zip_path}")
        modpack_zip_path.unlink()
    else:
        print(f"Did not find modpack zip at {modpack_zip_path} (probably a new install)")

    new_json_file = load_json_file(new_json_file_path)

    modpack_id: int = new_json_file["installedModpack"]["installedFile"]["projectId"]
    modpack_client_file_id: int = new_json_file["installedModpack"]["installedFile"]["id"]

    args.download_directory.mkdir(exist_ok=True, parents=True)
    base_modpack_zip_path = args.download_directory.joinpath("base-modpack.zip")

    curse_client = cursepy.CurseClient(args.curseforge_core_api_key)
    set_addon_file_formatter()
    modpack_server_file_id = curse_client.addon_file(modpack_id, modpack_client_file_id).server_pack_file_id
    curse_client.addon_file(modpack_id, modpack_server_file_id).download(str(base_modpack_zip_path))
    print("Downloaded base modpack")

    base_modpack_mods = {file["projectID"]: file["fileID"] for file in new_json_file["manifest"]["files"]}
    # Get mods that are not disabled
    actual_modpack_mods = {
        addon["installedFile"]["projectId"]: addon["installedFile"]
        for addon in new_json_file["installedAddons"]
        if not addon["installedFile"]["FileNameOnDisk"].endswith("disabled")
    }

    print(f"Found {len(base_modpack_mods)} mods in the base modpack and {len(actual_modpack_mods)} added")

    added_mods = {
        projectId: addon_file for projectId, addon_file in actual_modpack_mods.items()
        if projectId not in base_modpack_mods.keys()
    }

    print("Added mods:")
    for project_id, addon_file in added_mods.items():
        print(f"{project_id}: {addon_file['fileName']}")

    updated_mods = {
        projectId: addon_file for projectId, addon_file in actual_modpack_mods.items()
        if projectId in base_modpack_mods.keys() and addon_file["id"] != base_modpack_mods[projectId]
    }

    print("Updated mods:")
    for project_id, addon_file in updated_mods.items():
        print(f"{project_id}: {addon_file['fileName']}")

    disabled_mods = {
        addon["installedFile"]["projectId"]: addon["installedFile"]
        for addon in new_json_file["installedAddons"]
        if addon["installedFile"]["FileNameOnDisk"].endswith("disabled")
    }

    print("Disabled mods:")
    for project_id, addon_file in disabled_mods.items():
        print(f"{project_id}: {addon_file['fileName']}")

    files_to_delete = []
    for projectId, addon_file in {**updated_mods, **disabled_mods}.items():
        if projectId not in base_modpack_mods:
            continue
        old_file_id = base_modpack_mods[projectId]
        file_name = curse_client.addon_file(projectId, old_file_id).file_name
        files_to_delete.append(Path("mods").joinpath(file_name))

    for projectId, addon_file in {**added_mods, **updated_mods}.items():
        print(f"Downloading {addon_file['fileName']}...")
        addon: CurseFile = curse_client.addon_file(projectId, addon_file["id"])
        if not addon.download_url:
            print(f"**** Failed to get download URL for {addon.file_name} from Curseforge ****")
            project_id_part_one = int(addon.id / 1000)
            project_id_part_two = addon.id % 1000
            addon.download_url = \
                f"https://edge.forgecdn.net/files/{project_id_part_one}/{project_id_part_two}/{addon.file_name}"
        addon.download(path=str(args.download_directory))

    print("Finished donwloading mods")

    print("Packaging new zip...")
    mods_path = Path("mods")
    with ZipFile(base_modpack_zip_path, 'r') as base_modpack_zip, ZipFile(modpack_zip_path, 'w') as modpack_zip:
        for item in base_modpack_zip.infolist():
            zip_file_path = Path(item.filename)
            if zip_file_path in files_to_delete:
                print(f"Skipping {zip_file_path}")
                continue
            buffer = base_modpack_zip.read(item.filename)
            modpack_zip.writestr(item, buffer)
        for file in args.download_directory.glob("*"):
            print(f"Adding {file} to zip")
            if file.name == base_modpack_zip_path.name:
                continue
            zip_file_path = mods_path.joinpath(file.name)
            modpack_zip.write(file, zip_file_path)

    shutil.rmtree(args.download_directory, ignore_errors=True)
    shutil.copy2(new_json_file_path, old_json_file_path)

    print("Finished")


if __name__ == '__main__':
    main()
