#!/usr/bin/python3
# ============================== HOW TO USE ============================== #
#                                                              python 3.8+ #
#                                                                          #
# Just run the assets.py file from within the project folder. It'll try to #
# find the `.assetsignore` file if there is any, and use it just like it   #
# works for git with `.gitignore`. it may take some time to finish.        #
# ======================================================================== #

import sys
import re
from pathlib import Path
from enum import Enum
from collections import defaultdict, deque
from typing import List, Union

# ========================== EDITABLE CONSTANTS ========================== #
# where the code output should be put.
OUTPUT_FILE = "constants.dart"
# the `pubspec.yaml` file
PUBSPEC_FILE = "pubspec.yaml"
# where non-asset folders & files can be specified
ASSETS_IGNORE_FILE = ".assetsignore"

# comments for the output file to separate generated code from user created code
INIT_COMMENT = "\n// CODE GENERATED BY `assets.py` - DO NOT MODIFY BY HAND\n// (DO NOT REMOVE OR EDIT THESE COMMENTS EITHER)"""
LAST_COMMENT = "// --- END OF GENERATED CODE BY `assets.py` ---"

# regex for removing matching segments in output file and pubspec file
COMMENT_REGEX = r"\n\/\/ CODE GENERATED BY `assets\.py` - DO NOT MODIFY BY HAND\n\/\/ \(DO NOT REMOVE OR EDIT THESE COMMENTS EITHER\)(.|\n)+`assets.py` ---"
PUBSPEC_REGEX = r"(?<=\n)(flutter:\n(.|\n)+?assets:)(.|\n)+?(?=\n\w)"

# names for asset grouping when getting the final assets
GROUP_OTHER = "other"
GROUP_IMAGE = "image"
GROUP_MEDIA = "media"
GROUP_FONT = "font"
FILE_GROUPS = [
    (GROUP_IMAGE, ["png", "jpeg", "webp", "gif", "bmp", "wbmp", "heic", 
                   "heif"]),
    (GROUP_FONT, ["ttf", "otf"]),
    (GROUP_MEDIA, ["mp3", "aif", "ogg", "wav", "amr", "acc", "3gp", "mp4",
                   "m4a", "mkv", "webm", "ts"])
]

# max steps for how far back to search the project folder's location
MAX_BACK_STEPS_SEARCH = 10

# log level using addition of numbers, where:
#         _____________________________
# levels:   LOG  |  WARNING  |  ERROR
# values:    +1  |       +2  |     +4
#
# 7 means all levels (1 + 2 + 4)
LOG_LEVEL = 7

# ======================================================================== #

# default base asset class definition (dart)
ASSET_RESOURCE_CLASS = """\nclass AssetResource {
  final String name;

  const AssetResource(this.name);
}\n"""


# ansi colors
CYAN = "\033[38;5;39m"
RED = '\033[38;5;196m'
GREEN = '\033[38;5;82m'
YELLOW = '\033[38;5;184m'
END = "\033[0m"

# path for the project folder
project_folder = Path(".")

# enum type for logging info to stdout
class Level(Enum):
    # level    # color          # value
    LOG     = ('\033[38;5;34m',  1)  # green
    WARNING = ('\033[38;5;184m', 2)  # yellow
    ERROR   = ('\033[38;5;196m', 4)  # red

class FileType(Enum):
    pass

# show info in stdout
def log(msg, mtype:Level=Level.LOG, ignore_supress:bool=False):
    value = LOG_LEVEL
    should_log = False

    if (not ignore_supress):
        for level in list(Level)[::-1]:
            value -= level.value[1]

            if (value >= 0 and mtype == level): 
                should_log = True

            if (value < 0): 
                value += level.value[1]

        if LOG_LEVEL < 1 or not should_log: return

    print(f"[ {mtype.value[0]}{mtype.name}{END} ]: {msg}")

# raise error and exit
def raise_error(msg:str):
    log(msg, Level.ERROR, ignore_supress=True)
    sys.exit(1)

# show files with cool colors
def paint(file:str, quotes:bool=True, color=CYAN) -> str:
    return f"\"{color}{file}{END}\"" if quotes else f"{color}{file}{END}"


# an asset can be a directory or a file, and also holds current status when
# adding or removing if there are patterns that match.
class Asset(object):
    def __init__(self, path:Path, parent:'Asset'=None):
        global all_assets

        # if the asset already exists in `all_assets`, do not continue
        if path in all_assets:
            self.in_list = True

        # otherwise, create and add to `all_assets`
        else:
            self.in_list = False

            # absolute and relative path (from project folder)
            self.abspath = path
            self.relpath = split(str(project_folder.as_posix() + "/"), 
                                 str(path.as_posix()))[0]
            # the path split by it's segments
            self.path_parts = split("/", self.relpath)

            # asset's name including the suffix
            self.name = path.name
            # only the suffix part including the "." dot
            self.suffix = path.suffix
            # the asset's name without the suffix
            self.short = self.name[:-len(self.suffix)]

            # whether the asset is a file or a directory
            self.is_dir = path.is_dir()
            self.is_file = path.is_file()

            # the asset's parent
            self.parent = parent
            
            # whether the asset is locked and included
            self._locked = False
            self._included = True

            # if the asset should only appear in the pubspec and not in the 
            # output file
            self.only_pub = False

            # the asset's children
            self.children = []

            # add current asset to `all_assets`
            all_assets[self.abspath] = self

    # lock this asset and children, if any
    def lock(self):
        self._locked = True
        self._included = False

        if self.is_dir:
            self.find_children()

            for child in self.children:
                if child is not None:
                    child.lock()

    # a way of not including the files in the output file, 
    # but doing it in the pubspec
    def softlock(self):
        if self.is_dir:
            self.find_children()

            for child in self.children:
                if child is not None:
                    child.only_pub = True
        else:
            self.only_pub = True


    # set this asset to be included if not locked
    def include(self):
        if (not self._locked): 
            self._included = True

    # remove the asset
    def remove(self):
        self._included = False

    # return true if asset is locked
    def is_locked(self) -> bool:
        return self._locked

    # return true if asset is included
    def is_included(self) -> bool:
        return self._included

    # find children if any, and return the ammount found
    def find_children(self, ignore_locked:bool=False) -> int:
        self.children = []

        if self.is_file: 
            return 0

        for path in self.abspath.glob("*"):
            # first try finding it
            asset = Asset.find(path)

            # if unsuccessful
            if asset is None:
                asset = Asset.get(path, parent=self)

            if asset is not None:
                if ignore_locked and asset.is_locked():
                    continue
            
                self.children.append(asset)

        return len(self.children)

    # create asset and check if already in `all_assets`, then return it 
    @classmethod
    def get(cls, path:Path, parent:'Asset'=None) -> 'Asset':
        global all_assets

        asset = Asset(path, parent=parent)

        if asset.in_list:
            if parent is not None: all_assets[path].parent = parent
            return all_assets[path]

        all_assets[path] = asset
        asset.in_list = True
        return asset

    # return asset only if found in `all_assets`
    @classmethod
    def find(cls, path:Path) -> 'Union[Asset,None]':
        global all_assets

        return all_assets[path] if path in all_assets else None

    # object methods overriden for ordering and comparisons
    def __contains__(self, item:'Union[Asset,Path]') -> bool:
        if type(item) == Path:
            return item in self.abspath

        return item.path in self.abspath

    def __eq__(self, other:'Asset'):
        return other.path == self.abspath

    def __ne__(self, other):
        return other.path != self.abspath

    def __hash__(self) -> int:
        return hash(str(self.abspath))

# a pattern is added when using `.assetsignore` file. globbing patterns are
# replaced with regex patterns that match the logic.
class Pattern:
    def __init__(self, string:str):
        self.neg = string[0] == "!"
        self.only_dirs = string[-1] == "/"
        self.only_rel = string[1] == "/" if self.neg else string[0] == "/"
        self.only_pub = string[1] == "%" if self.neg else string[0] == "%"

        self.string = self.clean(string)

        # special chars match:  
        #                 "[]...]"      "[ ... ]"          "**"       "*"    "?"
        sp_chars = r"(\\?\[\][^\]]*\]|\\?\[[^\]]+\])|(/?\\?\*\*/?)|(\\?\*)|(\\?\?)" 
        
        self.pattern = '^' + '/'.join([
            ''.join([
                re.sub(sp_chars + r"|(.+)", self._repl, value) 
                     for value in split(sp_chars, part)
            ]) 
            for part in split(r"(?<!\*\*)/(?!\*\*)", self.string)
        ]) + '$'

    # method used to find and replace globbing patterns to regex
    def _repl(self, m_obj:re.Match) -> str:
        index, match = [
            (i, m) for i, m in enumerate(m_obj.groups())
            if m is not None
        ][0]

        if (match[0] == "\\"): 
            return match

        if index == 0:      # matches "[...]" 
            res = [
                re.escape(s) if s != "-" else s for s in split(r"(\-)", 
                                                               match[1:-1])
            ]

            return f"[{''.join(res)}]"

        elif index == 1:    # matches "**" 
            return (
                r"(.*/)?" if m_obj.end(index) != len(m_obj.string) 
                          else r".*"
            )

        elif index == 2:    # matches "*" 
            return r".*"

        elif index == 3:    # matches "?" 
            return r"."

        else: #index == 4   matches anything else
            return re.escape(match)

    # remove special prefix or suffix characters from pattern
    def clean(self, string:str) -> str:
        string = string[1:] if self.neg else string
        string = string[:-1] if self.only_dirs else string
        string = string[1:] if self.only_pub else string

        return string

    # perform regex match and return true if there is a match
    def does_match(self, asset:Asset) -> bool:

        if self.only_dirs and asset.is_file: return False

        return (re.match(self.pattern, asset.relpath) is not None,
                self.only_pub)

# a group of assets by their extension.
class ExtGroup:
    def __init__(self, group:str, ext_dict:defaultdict):
        self.group = group
        self.ext_dict = ext_dict

        self.is_other = self.group == GROUP_OTHER

        self.class_name = self.group.capitalize() + "Asset"

    # given the data, add either the pubspec info or output classes
    def save_to(self, data:deque, file:str): 
        values = ""

        # ammount of indentation
        d = "  "

        if file == "pubspec":
            # special case for the font group
            if self.group == GROUP_FONT:
                for assets in self.ext_dict.values():
                    values += f"\n{d}fonts:"
                    values += f"\n{d}- family: {assets[0].parent.name}"
                    d = "    "
                    values += f"\n{d}fonts:"

                    for asset in assets:
                        values += f"\n{d}- asset: {asset.relpath}"

                        if "bold" in asset.name.lower():
                            values += f"\n{d}  weight: 700"
                        
                        if "italic" in asset.name.lower():
                            values += f"\n{d}  style: italic"

                data.append(values)

            # if any other group, then just add as asset
            else:
                for assets in self.ext_dict.values():
                    for asset in assets:
                        values += f"\n{d}- {asset.relpath}"

                data.appendleft(values)

        elif file == "output":
            # special case for the font group
            if self.group == GROUP_FONT:
                values += (f"\n/// All available font families.\n"
                        + "// ignore: camel_case_types\n"
                        + f"class FontAsset {{\n")

                added_families = []

                for assets in self.ext_dict.values():
                    for asset in assets:
                        family = asset.parent.name

                        if family in added_families: 
                            continue

                        added_families.append(family)                   
        
                        values += (f"\n{d}/// Font family: `{family}`"
                            + f"\n{d}// ignore: non_constant_identifier_names"
                            + f", unused_field\n{d}"
                            + f"static final String {snake(family)[:-1]} = "
                            + f"\"{family}\";\n")

                values += "\n}\n"
                data.append(values)
                return

            # otherwise, if any group but `other`, do subclasses
            if not self.is_other:
                values += (f"\n/// All available `{self.group}` assets.\n"
                        + "// ignore: camel_case_types\n"
                        + f"class {self.class_name} {{\n")

                for ext in self.ext_dict.keys():
                    values += (f"\n{d}// ignore: "
                            + "non_constant_identifier_names\n"
                            + f"{d}static const {ext} = _{ext.capitalize()}"
                            + "Asset();\n")

                values += "\n}\n"


            # add each class for the type of extensions or suffixes
            for ext, assets in self.ext_dict.items():
                values += (f"\n/// All available `{ext}` assets.\n"
                        + "// ignore: camel_case_types\nclass "
                        + ('' if self.is_other else '_')
                        + f"{ext.capitalize()}Asset {{\n")

                if not self.is_other:
                    values += f"\n{d}const _{ext.capitalize()}Asset();\n"

                # saves a dictionary with: [ <ext> ][ <asset.name> ] = (int)
                used = defaultdict(lambda: defaultdict(int))

                for asset in assets:

                    if asset.only_pub: continue

                    #fix name if it repeats
                    if (asset.name in used[ext] or used[ext][asset.name] > 0):
                        used[ext][asset.name] += 1
                        asset.short += "$" + str(used[ext][asset.name])

                    values += (f"\n{d}/// Asset from file: `{asset.relpath}`"
                            + f"\n{d}// ignore: non_constant_identifier_names"
                            + f", unused_field\n{d}"
                            + ("static " if self.is_other else "")
                            + f"final {snake(asset.short)} = const "
                            + ("AssetResource" if self.group != GROUP_IMAGE 
                                               else "AssetImage")
                            + f"(\"{asset.relpath}\");\n")

                values += "\n}\n"

            data.append(values)


# use re.split and remove unwanted elements
def split(pattern:str, string:str) -> List[List[str]]:
    return [
        value for value in re.split(pattern, string) 
        if value is not None and value != ""
    ]

# search backwards recursively from the current working directory first
def find_project_folder() -> bool:
    global project_folder
    attempts = MAX_BACK_STEPS_SEARCH
    project_folder = Path.cwd().resolve()

    res = sorted(project_folder.rglob(".git"))
    
    while (attempts > 0 and len(res) == 0):
        project_folder = project_folder.parent

        res = sorted(project_folder.rglob(".git"))
        attempts -= 1  

    return len(res) > 0

# search recursively for a file given only its name
def find(file:str) -> Asset:
    res = [path for path in project_folder.rglob(file)]

    if len(res) > 0:
        if len(res) > 1: 
            log(f"found more than one match for {paint(file)}, will only use: {paint(res[0])}", Level.WARNING)
        return Asset.get(res[0])
    
    return None

# return the input string with snake case
def snake(string:str):
    s = re.sub(r'([a-z0-9])([A-Z])', r'\1_\2_', 
               re.sub(r'(.)([A-Z][a-z]+)', r'\1_\2_', string)
        ).lower()

    return re.sub(r'\.|-|~|@', "_", s)

# get which group the object belongs to based on it's extensions (suffix)
def get_group(obj:Union[Asset, Path]) -> str:
    group = GROUP_OTHER

    for _group, _ext_list in FILE_GROUPS:
        if obj.suffix[1:] in _ext_list: 
            group = _group

    return group

# main app
def main():
    global project_folder, all_assets
    log("initializing...")


    # if project folder can't be found, then exit.
    if ( not find_project_folder() ): 
        raise_error("stopping because project folder could not be located")


    # saves all patterns if file `.assetsignore` is used
    all_patterns = list()

    # holds all assets with structure: < key:path, value:asset(path) >
    all_assets = dict()

    # a growing list of assets for pattern matching (if needed)
    directories = [Asset.get(path) for path in project_folder.glob("*")]
    
    # final dictionary of file-only assets with structure: 
    # < key: group, value: <key:asset.suffix, value:asset > >
    final_assets = defaultdict(lambda: defaultdict(list))


    # find important files and lock them to avoid any problems
    find(".git").lock()
    find(".gitignore").lock()
    find("assets.py").lock()

    # find output file, lock it, and retrieve data onto `output_data`
    output_asset = find(OUTPUT_FILE)

    if output_asset is None:
        raise_error(f"stopping because output file: {paint(OUTPUT_FILE)} could not be located")

    output_asset.lock()

    with open(output_asset.abspath) as output_file:
        output_data = output_file.read()

        # remove parts that will be added later
        output_data = re.sub(COMMENT_REGEX, "", output_data)


    # find pubspec file, lock it, and retrieve data onto `pubspec_data`
    pubspec_asset = find(PUBSPEC_FILE)

    if pubspec_asset is None:
        raise_error(f"stopping because pubspec file: {paint(PUBSPEC_FILE)} could not be located")

    pubspec_asset.lock()

    with open(pubspec_asset.abspath) as pubspec_file:
        pubspec_data = pubspec_file.read()

        # remove parts that will be added later
        pubspec_data = re.sub(PUBSPEC_REGEX, r"\1<ASSETS>", pubspec_data, re.DOTALL)


    log("locating assets...")


    # find assetsignore file if used
    ignore_asset = find(ASSETS_IGNORE_FILE)
    if ignore_asset is None:
        log(f"{paint(ASSETS_IGNORE_FILE)} could not be located, this will make all files in project folder be included as assets", Level.WARNING)

        for path in project_folder.rglob("*"):
            if path.is_file():
                g = get_group(path)
                final_assets[g][path.suffix[1:]].append(Asset.get(path))


    else:
        # lock the file if found
        ignore_asset.lock()

        # read the .assetsignore file and save each pattern found in 
        # `all_patterns`.
        with open(ignore_asset.abspath) as assets_ignore_file:
            skip = ["", "#"]

            for i, line in enumerate(assets_ignore_file.readlines()):
                line = line.strip(" \n")

                if (len(line) > 0 and line[0] not in skip): 
                    all_patterns.append(Pattern(line))

        # for each asset, test all patterns available
        for asset in directories:
            # if there is a match (true), then do not include
            match = False

            for pattern in all_patterns:
                match, only_pub = pattern.does_match(asset)

                if match:
                    # if asset gets matched for the first time, and it's 
                    # a directory, then continue with next asset
                    if asset.is_dir and not only_pub:
                        asset.lock()
                        break

                    if only_pub:
                        asset.softlock()
                        pattern.neg = not pattern.neg
                    
                    # include or remove depending on the patterns' state
                    asset.include() if pattern.neg else asset.remove()

            if asset.is_included():  
                # find children if any, but ignore locked directories
                nchildren = asset.find_children(ignore_locked=True)
                
                # add children to directories that can be checked against 
                # patterns 
                if nchildren > 0:
                    directories += [
                        child for child in asset.children 
                              if not child.is_locked()
                    ]

                # add files to a dict separated by their extensions
                if asset.is_file:
                    g = get_group(asset)

                    final_assets[g][asset.suffix[1:]].append(asset)

    log("writing to files...")
    # iterate one time through all final assets to add 
    # the importan data onto `output_data` and `pubspec_data`
    pubspec_res = deque()
    output_res = deque([ASSET_RESOURCE_CLASS])

    # a list of used names in a class
    names = []

    # loop for each extension and asset list in `final_assets`
    for group, ext_dict in final_assets.items():
        ext_group = ExtGroup(group, ext_dict)

        ext_group.save_to(pubspec_res, file="pubspec")
        ext_group.save_to(output_res, file="output")

    # open pubspec.yaml file and replace all with the new data
    with open(pubspec_asset.abspath, "w") as pubspec_file:
        pubspec_file.write(pubspec_data.replace("<ASSETS>", "".join(
            pubspec_res
        )))
    
    # open constants.dart file and replace all with the new data
    with open(output_asset.abspath, "w") as output_file:
        output_file.write(f"{output_data}{INIT_COMMENT}"
                          + ''.join(output_res) + LAST_COMMENT)

    # finished the program
    log("done.")


if __name__ == "__main__":
    main()