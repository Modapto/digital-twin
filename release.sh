#!/usr/bin/env bash
#
VERSION=$1
NEXTVERSION=$2
if [[ -z "$3" ]]; then
  NEXTBRANCH=$(sed -n 's/^\s\+<tag>\([^<]\+\)<\/tag>/\1/p' pom.xml)
else
  NEXTBRANCH=$3
fi
TAG_VERSION="version"
TAG_CHANGELOG_HEADER="changelog-header"
TAG_CHANGELOG_ANCHOR="changelog-anchor"
README_FILE="README.md"
WORKFLOW_FILE=".github/workflows/image-ci-cd.yml"

# arguments: tag
function startTag()
{
	echo "<!--start:$1-->\\n"
}

# arguments: tag
function endTag()
{
	echo "<!--end:$1-->"
}

# arguments: file, tag, newValue, originalValue(optional, default: matches anything)
function replaceValue()
{
	local file=$1
	local tag=$2
	local newValue=$3
	local originalValue=${4:-.*}
	local startTag=$(startTag "$tag")
	local endTag=$(endTag "$tag")
	sed -r -z "s/$startTag($originalValue)$endTag/$startTag$newValue$endTag/g" -i "$file"
}

# arguments: file, tag
function removeTag()
{
	local file=$1
	local tag=$2
	local startTag=$(startTag "$tag")
	local endTag=$(endTag "$tag")
	sed -r -z "s/$startTag(.*)$endTag/\1/g" -i "$file"
}

echo "Releasing:  ${VERSION},
tagged:    v${VERSION},
next:       ${NEXTVERSION}-SNAPSHOT
nextBranch: ${NEXTBRANCH}"
echo "Press enter to go"
read -s

echo "Replacing version numbers"
replaceValue "$README_FILE" "$TAG_CHANGELOG_HEADER" "## ${VERSION}"
removeTag "$README_FILE" "$TAG_CHANGELOG_HEADER"
sed -i "/VERSION:/s/: .*/: ${VERSION}/" "${WORKFLOW_FILE}"
git -C faaast-smt-simulation-processor fetch --tags
git -C faaast-smt-simulation-processor checkout tags/v"${VERSION}"

echo "Git add ."
git add .

echo "Next: git commit & Tag [enter]"
read -s
git commit -m "Release v${VERSION}"
git tag -m "Release v${VERSION}" -a v"${VERSION}"

echo "Next: replacing version nubmers [enter]"
read -s
sed -i "/^<!--${TAG_CHANGELOG_ANCHOR}-->$/a <!--start:${TAG_CHANGELOG_HEADER}-->\\n<!--end:${TAG_CHANGELOG_HEADER}-->" "$README_FILE"
replaceValue "$README_FILE" "$TAG_CHANGELOG_HEADER" "## ${NEXTVERSION}-SNAPSHOT (current development version)"
sed -i "/VERSION:/s/: .*/: ${NEXTVERSION}/" "${WORKFLOW_FILE}"
git -C faaast-smt-simulation-processor checkout main
git -C faaast-smt-simulation-processor pull origin main

echo "Git add ."
git add .

echo "Next: git commit [enter]"
read -s
git commit -m "Prepare for next development iteration"

echo "Done"
