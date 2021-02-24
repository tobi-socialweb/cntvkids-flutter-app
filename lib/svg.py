#!/usr/bin/python3
import os
import sys
import re
import argparse
import pathlib

HELPER_FILE = "helper"
R_G_FILE = "r_g"
COMMENT_FIRST_LINE = "// CODE GENERATED BY `svg.py` - DO NOT MODIFY BY HAND"
COMMENT_LINES = COMMENT_FIRST_LINE + """\n// (DO NOT REMOVE OR EDIT THESE COMMENTS EITHER)"""
COMMENT_LAST_LINE = "// " + "-" * 5

def main():
    # get top level directory (project folder).
    dir = re.sub(r"(?<=cntvkids-flutter-app).*", "", os.getcwd())

    # get both full paths to `helpers.dart` and `r.g.dart`.
    files = dict()
    for (helper_path, r_g_path) in zip(pathlib.Path(dir).rglob("helpers.dart"), 
            pathlib.Path(dir).rglob("r.g.dart")):

        files[HELPER_FILE] = helper_path.absolute()
        files[R_G_FILE] = r_g_path.absolute()

    # open `helpers.dart` and see if there was generated code before.
    with open(files[HELPER_FILE]) as helper_file:
        # get all the `helpers.dart` file
        helper_data = helper_file.read()

        # search and clean if there is an instance of generated code
        # re flags when searching.
        flags = re.MULTILINE | re.DOTALL

        # regular expression for searching generated code
        re_gen_code = re.escape(COMMENT_LINES) + r"[^¡]+" + COMMENT_LAST_LINE + r"[ \t]*\n?"

        # remove if found
        helper_data = re.sub(re_gen_code, "", helper_data, flags)
        

    # open `r.g.dart` and retrieve all svg icons and paths onto `svg_icons`.
    with open(files[R_G_FILE]) as r_g_file:
        # get all the `r.g.dart` file
        r_g_data = r_g_file.read()

        # regular expressions for searching icon info.
        re_icon_names = r"(?<=AssetSvg ).+?(?=\()"
        re_icon_paths = lambda  name : rf"final {re.escape(name)} = const AssetResource\(\s*?\"(.+?\.svg)\""

        # the final list of svg icons with each element being [(<icon_name>, <icon_path>), ... ].
        svg_icons = [(name, re.search(re_icon_paths(name), r_g_data).group(1)) 
                        for name in re.findall(re_icon_names, r_g_data, flags)]

    # add newly found icons into the `helpers.dart` file
    with open(files[HELPER_FILE], "w") as helper_file:
        helper_file.write(helper_data + COMMENT_LINES + "\n\n/// All of the available svg assets.\nclass SvgAsset {")

        for icon_name, icon_path in svg_icons:
            helper_file.write(f"\n\n  ///asset from file: `{icon_path}`\n  // ignore: non_constant_identifier_names\n  static final String {icon_name} = \"{icon_path}\";")
    
        helper_file.write("\n\n}\n" + COMMENT_LAST_LINE)

if __name__ == "__main__":
    main()