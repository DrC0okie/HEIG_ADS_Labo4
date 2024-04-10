#!/bin/bash

raw_dir="lab04_raw_files"
files_dir="files"  # Directory where originals and thumbnails will be stored
output_file="page.html"
template_begin="template_begin.html"
template_middle="template_middle.html"
template_end="template_end.html"

# Ensure the files directory exists
mkdir -p "$files_dir"

# Ensure the middle content file is empty before starting
> "$template_middle"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed. Please install it to continue."
    exit 1
fi

# Generate the middle section for images
echo -e "<article class=\"container article\">\n<div class=\"row\">\n<div class=\"col-md-10 col-md-pull-3 col-md-offset-4 article__content\">\n<div><div><h2>Découvrez-nous en images</h2></div></div>\n<div class=\"row\">" >> "$template_middle"

# Copy images to files directory and create thumbnails
for img in "$raw_dir"/*.{jpg,png}; do
    [ -e "$img" ] || continue  # Skip if no files found
    filename=$(basename "$img")
    # Copy the original image to the files directory
    cp "$img" "$files_dir/$filename"
    # Generate a thumbnail in the files directory
    thumbnail="${filename%.*}_thumb.${filename##*.}"
    convert "$files_dir/$filename" -resize 200x200 "$files_dir/$thumbnail"
    echo -e "<div class=\"col-md-6 col-xs-12\">\n<a href=\"$files_dir/$filename\"><img class=\"vignette\" src=\"$files_dir/$thumbnail\" /></a>\n</div>" >> "$template_middle"
done

echo -e "</div>\n</div>\n</div>\n<div class=\"row\" style=\"margin-top: 40px;\">\n<div class=\"col-md-10 col-md-pull-3 col-md-offset-4 article__content\">\n<div><div><h2>Téléchargez nos brochures</h2></div></div>\n<div class=\"row\">" >> "$template_middle"

# Copy brochures to files directory
for pdf in "$raw_dir"/*.pdf; do
    [ -e "$pdf" ] || continue  # Skip if no files found
    pdf_filename=$(basename "$pdf")

    # Copy the PDF to the files directory
    cp "$pdf" "$files_dir/$pdf_filename"

    # Generate a thumbnail for the first page of the PDF in the files directory
    thumbnail="${pdf_filename%.*}_thumb.jpg"
    convert -geometry 300 "$files_dir/$pdf_filename[0]" "$files_dir/$thumbnail"
    echo -e "<div class=\"col-md-6 col-xs-12\">\n<a href=\"$files_dir/$pdf_filename\"><img class=\"vignette\" src=\"$files_dir/$thumbnail\" /></a>\n</div>" >> "$template_middle"
done

echo -e "</div>\n</div>\n</div>\n</article>\n" >> "$template_middle"

# Concatenate the beginning template, the generated middle content, and the end template, then write to the page.html file
cat "$template_begin" "$template_middle" "$template_end" > "$output_file"
