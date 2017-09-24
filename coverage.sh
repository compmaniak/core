#!/bin/sh

failure() {
  echo "Failed to build coverage report: $1."
  exit 1
}

check_utility() {
  if ! type $1 > /dev/null; then
    failure "$1 is not installed"
  fi
}

check_utility lcov
check_utility genhtml
# Checking for source notes files
if [ -z "$(find src/lib -name '*.gcno')" ]; then
  failure "sources are built without coverage support"
fi

trace_files=""
for lib_path in $(find src -type d -not -name '.*'); do
  trace_file="$lib_path/coverage.info"
  lcov -o $trace_file -c -b $lib_path -d $lib_path/.libs --no-recursion
  trace_file_size=$(stat --format=%s $trace_file)
  if [ $trace_file_size -gt 0 ]; then
    trace_files="$trace_files $trace_file"
  fi
done

rm -rf coverage
genhtml --num-spaces 4 --legend --function-coverage --demangle-cpp \
        --title "Dovecot coverage" -o coverage $trace_files
