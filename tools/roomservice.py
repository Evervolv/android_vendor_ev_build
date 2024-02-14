#!/usr/bin/env python3
# Copyright (C) 2012-2013, The CyanogenMod Project
#           (C) 2017-2018,2020-2021, The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import print_function

import base64
import json
import netrc
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

from xml.etree import ElementTree

product = sys.argv[1]

if len(sys.argv) > 2:
    depsonly = sys.argv[2]
else:
    depsonly = None

try:
    device = product[product.index("_") + 1:]
except:
    device = product

if not depsonly:
    print("Device %s not found. Attempting to retrieve device repository from Evervolv Github (http://github.com/Evervolv)." % device)

repositories = []

try:
    authtuple = netrc.netrc().authenticators("api.github.com")

    if authtuple:
        auth_string = ('%s:%s' % (authtuple[0], authtuple[2])).encode()
        githubauth = base64.encodestring(auth_string).decode().replace('\n', '')
    else:
        githubauth = None
except:
    githubauth = None

def add_auth(githubreq):
    if githubauth:
        githubreq.add_header("Authorization","Basic %s" % githubauth)

if not depsonly:
    githubreq = urllib.request.Request("https://api.github.com/search/repositories?q=%s+user:Evervolv+in:name+fork:true" % device)
    add_auth(githubreq)
    try:
        result = json.loads(urllib.request.urlopen(githubreq).read().decode())
    except urllib.error.URLError:
        print("Failed to search GitHub")
        sys.exit(1)
    except ValueError:
        print("Failed to parse return data from GitHub")
        sys.exit(1)
    for res in result.get('items', []):
        repositories.append(res)

local_manifests = r'.repo/local_manifests'
if not os.path.exists(local_manifests): os.makedirs(local_manifests)

def exists_in_tree(lm, path):
    for child in lm.getchildren():
        if child.attrib['path'] == path:
            return True
    return False

# in-place prettyprint formatter
def indent(elem, level=0):
    i = "\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            indent(elem, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

def get_from_manifest(devicename):
    for manifest in os.listdir(".repo/local_manifests"):
        try:
            lm = ElementTree.parse(os.path.join(".repo/local_manifests", manifest))
            lm = lm.getroot()
        except:
            lm = ElementTree.Element("manifest")

        for localpath in lm.findall("project"):
            if re.search("android_device_.*_%s$" % device, localpath.get("name")):
                return localpath.get("path")

    return None

def is_in_manifest(projectpath):
    for manifest in os.listdir(".repo/local_manifests"):
        try:
            lm = ElementTree.parse(os.path.join(".repo/local_manifests", manifest))
            lm = lm.getroot()
        except:
            lm = ElementTree.Element("manifest")

        for localpath in lm.findall("project"):
            if localpath.get("path") == projectpath:
                return True

    # Search in main manifest, too
    try:
        lm = ElementTree.parse(".repo/manifest.xml")
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for localpath in lm.findall("project"):
        if localpath.get("path") == projectpath:
            return True

    # ... and don't forget the snippets
    for snippet in os.listdir(".repo/manifests/snippets"):
        try:
            lm = ElementTree.parse(".repo/manifests/snippets/%s.xml" % snippet)
            lm = lm.getroot()
        except:
            lm = ElementTree.Element("manifest")

        for localpath in lm.findall("project"):
            if localpath.get("path") == projectpath:
                return True

    return False

def add_to_manifest(repositories, fallback_branch = None):
    for repository in repositories:
        repo_name = repository['repository']
        repo_target = repository['target_path']

        aosp = False
        if ("/" in repo_name):
            aosp = True

        if aosp:
            dep_type = repo_name.split('/')[0]
        else:
            dep_type = repo_name.split('_')[1]

        dep_manifest = ".repo/local_manifests/%s.xml" % dep_type
        try:
            lm = ElementTree.parse(dep_manifest)
            lm = lm.getroot()
        except:
            lm = ElementTree.Element("manifest")

        print('Checking if %s is fetched from %s' % (repo_target, repo_name))
        if is_in_manifest(repo_target):
            print('%s already fetched to %s' % (repo_name, repo_target))
            continue

        print('Adding dependency: %s -> %s' % (repo_name, repo_target))
        project = ElementTree.Element("project", attrib = { "path": repo_target,
            "name": "%s" % repo_name })

        if 'remote' in repository:
            project.set('remote',repository['remote'])
        else:
            project.set('remote',"evervolv")

        if 'branch' in repository:
            project.set('revision',repository['branch'])
        elif fallback_branch:
            print("Using fallback branch %s for %s" % (fallback_branch, repo_name))
            project.set('revision', fallback_branch)
        elif not aosp:
            print("Using default branch for %s" % repo_name)

        lm.append(project)

        indent(lm, 0)
        raw_xml = ElementTree.tostring(lm).decode()
        raw_xml = '<?xml version="1.0" encoding="UTF-8"?>\n' + raw_xml

        f = open(dep_manifest, 'w')
        f.write(raw_xml)
        f.close()

def fetch_dependencies(repo_path, fallback_branch = None):
    print('Looking for dependencies in %s' % repo_path)
    dependencies_path = repo_path + '/ev.dependencies'
    syncable_repos = []
    verify_repos = []

    if os.path.exists(dependencies_path):
        dependencies_file = open(dependencies_path, 'r')
        dependencies = json.loads(dependencies_file.read())
        fetch_list = []

        for dependency in dependencies:
            if not is_in_manifest(dependency['target_path']):
                fetch_list.append(dependency)
                syncable_repos.append(dependency['target_path'])
                verify_repos.append(dependency['target_path'])
            else:
                verify_repos.append(dependency['target_path'])

            if not os.path.isdir(dependency['target_path']):
                syncable_repos.append(dependency['target_path'])

        dependencies_file.close()

        if len(fetch_list) > 0:
            print('Adding dependencies to manifest')
            add_to_manifest(fetch_list, fallback_branch)
    else:
        print('%s has no additional dependencies.' % repo_path)

    if len(syncable_repos) > 0:
        print('Syncing dependencies')
        os.system('repo sync --force-sync %s' % ' '.join(syncable_repos))

    for deprepo in verify_repos:
        fetch_dependencies(deprepo)

def has_branch(branches, revision):
    return revision in [branch['name'] for branch in branches]

if depsonly:
    repo_path = get_from_manifest(device)
    if repo_path:
        fetch_dependencies(repo_path)
    else:
        print("Trying dependencies-only mode on a non-existing device tree?")

    sys.exit()

else:
    for repository in repositories:
        repo_name = repository['name'].replace("_moto_", "_motorola_")
        if re.match(r"^android_device_[^_]*_" + device + "$", repo_name):
            print("Found repository: %s" % repo_name)
            manufacturer = repo_name.replace("android_device_", "").replace("_" + device, "")
            repo_path = "device/%s/%s" % (manufacturer, device)

            adding = {'repository':repo_name,'target_path':repo_path}
            add_to_manifest([adding])

            print("Syncing repository to retrieve project.")
            os.system('repo sync -c --force-sync %s' % repo_path)
            print("Repository synced!")

            fetch_dependencies(repo_path)
            print("Done")
            sys.exit()

print("Repository for %s not found in the Evervolv Github repository list. If this is in error, you may need to manually add it to your local_manifests." % device)
