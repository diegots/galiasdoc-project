# GaliasDoc: information extraction from PDF sources with common templates
# Copyright (C) 2021 Diego Trabazo Sardón
#
# This file is part of GaliasDoc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>

build_dir := build
conf_dir := conf
data_dir := data
distribute_dir := dist
engine_dir := engine
script_dir := script
plugin_dir := plugin
templates_dir := templates
training_data_dir := training-*
tool_gen_cif_dir := tool-gen-cif
tool_gen_language := tool-gen-language
tool_parser_dir := tool-parser

all: dist

build:
	$(MAKE) -C $(tool_parser_dir)

dist: build
	mkdir -p $(distribute_dir)/$(tool_gen_language) $(distribute_dir)/$(tool_parser_dir)/$(plugin_dir)
	mkdir -p $(distribute_dir)/$(script_dir)
	cp -R $(data_dir) $(distribute_dir)
	cp -R $(conf_dir) $(distribute_dir)
	cp -R $(tool_gen_language)/src/* $(distribute_dir)/$(tool_gen_language)
	cp -R $(engine_dir) $(distribute_dir)
	cp -R $(script_dir)/run-docker-* $(distribute_dir)/$(script_dir)
	mv $(tool_parser_dir)/parser $(distribute_dir)/$(tool_parser_dir)
	mv $(tool_parser_dir)/*.so $(distribute_dir)/$(tool_parser_dir)/$(plugin_dir)

clean:
	$(MAKE) -C $(tool_parser_dir) clean
	rm -rf $(build_dir) $(distribute_dir)
	rm -f vgcore.*
	rm -rf $(tool_gen_language)/src/code/__pycache__ # generado durante development

.PHONY: all build dist clean

