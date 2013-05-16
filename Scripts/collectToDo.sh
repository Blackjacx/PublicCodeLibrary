#!/bin/sh

TODOS_FILE_PATH="./todos.txt"
SOURCE_ROOT_DIR="$SRCROOT"

echo "Writing TODOs to $TODOS_FILE_PATH"

grep -n -A 4 -w "TODO\|FIXME\|HACK\|TEMP\|BUG" $( find "$SOURCE_ROOT_DIR" -name "*.h" -o -name "*.m" -exec echo "{}" \; ) | sed "s/.*Classes//g" | sed "s/.*Sources//g" > "$TODOS_FILE_PATH"