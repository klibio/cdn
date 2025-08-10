#!/usr/bin/env bash
# Export all .drawio files' diagrams as SVG and PNG into ./images/

set -e
dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export diagram_file_path=./diagrams
export png_target_path=./diagrams/png

# Create images directory if it doesn't exist
mkdir -p "$png_target_path"

function export_sanitized_diagram {
diagram_file_name=$1
echo -e "Exporting $diagram_file_path/$diagram_file_name"
# Get diagram info. No need for --uncompressed : care only about <diagram name="..." ...> part.
draw.io --export --format xml \
    --output $diagram_file_path/$diagram_file_name.xml \
    --page-index 0 \
    $diagram_file_path/$diagram_file_name.drawio

# grep -Eo "name=\"[^\"]*": get name="... tokens/matches from xml
# cut -c7-: get diagram name (everything but starting 'name="'')
# sed -e 's/[^a-zA-Z0-9_]/_/: replace all possible unsafe charactecter for file names with underscore (_) 
# tr '[:upper:]' '[:lower:]': make all lower case
# awk '{print NR,$1}': add sequence number (NR) to output to indicate index of diagram
# xargs -n2 sh -c: get 2 arguments (index and sanitized driagram name) and pass to shell command
# drawio --export...: export diagram at specified index (0-based) to PNG
cat $diagram_file_path/$diagram_file_name.xml \
    | grep -Eo "name=\"[^\"]*" \
    | cut -c7- \
    | sed -e 's/[^a-zA-Z0-9_]/_/g' \
    | tr '[:upper:]' '[:lower:]' \
    | awk '{print NR,$1}' \
    | xargs -n2 sh -c \
    'draw.io --export --format png --output $png_target_path/$1.png --page-index $(expr $0 - 1) $diagram_file_path/$diagram_file_name.drawio'

rm $diagram_file_path/$diagram_file_name.xml
}

# Find all .drawio files in the repo
find . -type f -name '*.drawio' | while read -r file; do
  base=$(basename "$file" .drawio)
  export_sanitized_diagram "$base"
done

