#!/usr/bin/env zsh

# test for sni.zsh
#
# run command:
#
# $ zsh sni.test.zsh

set -Cuo pipefail

TEST_DIR=$PWD/test_dir

mkdir -p $TEST_DIR
curl -sS https://raw.githubusercontent.com/yosugi/assert.bash/v0.2.0/assert.bash > $TEST_DIR/assert.bash
source $TEST_DIR/assert.bash

SNI_DIR=$TEST_DIR/sni
SNI_FILENAME=snippets.txt
SNI_HOSTNAME=localhost

source ./sni.zsh

# override for test
function _sni-print-z() {
    echo "$@"
}

function _sni-trim_test() {
    echo ${funcstack[1]}

    local actual
    actual=$(echo "test" | _sni-trim)
    assert $actual = "test"

    actual=$(echo "  test" | _sni-trim)
    assert $actual = "test"

    actual=$(echo "test  " | _sni-trim)
    assert $actual = "test"

    actual=$(echo "  test  " | _sni-trim)
    assert $actual = "test"

    actual=$(echo "\ttest\t" | _sni-trim)
    assert $actual = "test"
}
_sni-trim_test

function _sni-remove-comment_test() {
    echo ${funcstack[1]}

    local actual
    actual=$(echo "/* comment */ ls -al" | _sni-remove-comment)
    assert $actual = " ls -al"

    actual=$(echo "/* comment */ ls */ -al" | _sni-remove-comment)
    assert $actual = " ls */ -al"

    actual=$(echo "ls -al /* comment */" | _sni-remove-comment)
    assert $actual = "ls -al "

    actual=$(echo "ls /* -al /* comment */" | _sni-remove-comment)
    assert $actual = "ls /* -al "

    actual=$(echo " ls /* comment */ -al " | _sni-remove-comment)
    assert $actual = " ls /* comment */ -al "

}
_sni-remove-comment_test

function _sni-init_test() {
    local sni_init_test_dir1
    local sni_init_test_dir2
    local sni_local_file
    local actual

    echo ${funcstack[1]}

    sni_files="test1.txt\ntest2.txt\ntest3.txt\ntest4.txt"

    # local snippet test
    sni_init_test_dir1="${TEST_DIR}/sni-init_test1"
    mkdir -p $sni_init_test_dir1
    echo $sni_files | xargs -I{} echo "${sni_init_test_dir1}/{}" | _sni-init false

    # exists only local snippet file
    assert ! -f "${sni_init_test_dir1}/test1.txt"
    assert ! -f "${sni_init_test_dir1}/test2.txt"
    assert -f "${sni_init_test_dir1}/test3.txt"
    assert ! -f "${sni_init_test_dir1}/test4.txt"

    # directory snippet test
    sni_init_test_dir2="${TEST_DIR}/sni-init_test2"
    mkdir -p $sni_init_test_dir2
    echo $sni_files | xargs -I{} echo "${sni_init_test_dir2}/{}" | _sni-init true

    # exists local and directory snippet files
    assert -f "${sni_init_test_dir2}/test1.txt"
    assert ! -f "${sni_init_test_dir2}/test2.txt"
    assert -f "${sni_init_test_dir2}/test3.txt"
    assert ! -f "${sni_init_test_dir2}/test4.txt"
}
_sni-init_test

function _sni-get-local-sni-files_test() {
    local hoge_dir

    hoge_dir="/path1/path2/path3"

    actual=$(_sni-get-local-sni-files "$TEST_DIR" "$SNI_FILENAME" "$hoge_dir")

    expect="${TEST_DIR}/path1/path2/path3/$SNI_FILENAME
${TEST_DIR}/path1/path2/$SNI_FILENAME
${TEST_DIR}/path1/$SNI_FILENAME
${TEST_DIR}/$SNI_FILENAME"

    assert $actual = $expect
}
_sni-get-local-sni-files_test


# function _sni-manipulate_test() {
#     echo ${funcstack[1]}
#     local sni_manipulate_test_dir="$test_dir/sni-manipulate_test"
# 
#     mkdir -p $sni_manipulate_test_dir
#     cd $sni_manipulate_test_dir
# 
#     _sni-init > /dev/null
# 
#     local sni_local_file=$(sni f)
#     local actual expect
# 
#     # sni push
#     actual=$(_sni-push $sni_local_file "ls -al")
#     assert $actual match "1.ls -al"
# 
#     _sni-push $sni_local_file "https://www.example.com/" > /dev/null
#     _sni-push $sni_local_file "/path/to/work/dir.txt" > /dev/null
# 
#     # sni get
#     actual=$(_sni-get $sni_local_file 1)
#     assert $actual = "ls -al"
# 
#     actual=$(_sni-get $sni_local_file 2)
#     assert $actual = "https://www.example.com/"
# 
#     actual=$(_sni-get $sni_local_file 4)
#     assert -z $actual
# 
#     # sni $
#     actual=$(_sni-last $sni_local_file)
#     assert $actual = "/path/to/work/dir.txt"
# 
#     # sni pop
#     actual=$(_sni-pop $sni_local_file)
#     assert $actual match "1.*ls -al"
#     assert $actual match "https://www.example.com/"
# }
# _sni-manipulate_test

rm -rf $TEST_DIR
