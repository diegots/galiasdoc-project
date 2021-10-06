#!/usr/bin/env bash

# Ejecución del engine

job_id="$1"

$engine_dir/unpack.sh $job_id
$engine_dir/extract-text.sh $job_id
$engine_dir/split-text-from-image.sh $job_id
$engine_dir/extract-images.sh $job_id
$engine_dir/extract-text-coords.sh $job_id
$engine_dir/generate-images-for-text-based.sh $job_id
$engine_dir/image-apply-ocr.sh $job_id
$engine_dir/identify-grep.sh $job_id
$engine_dir/generate-json.sh $job_id
$engine_dir/populate-result.sh $job_id
