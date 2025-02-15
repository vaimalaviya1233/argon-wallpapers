SHELL = bash
WALLPAPERS = $(wildcard ./*.png) #$(wildcard ./wide/*png)
SVG = $(wildcard ./*.svg)

#Support 16:10 and 16:9 aspect ratios
ifeq ($(GENERATE_WIDE),true)
  CLIP_HEIGHT=2400
  EXPORT_HEIGHT=2400
  EXPORT_DIR=wide/
else
  CLIP_HEIGHT=2160
  EXPORT_HEIGHT=2160
  EXPORT_DIR=./
endif

CLIP_WIDTH=3840
EXPORT_WIDTH=3840
EXPORT_REGION=0:0:$(CLIP_WIDTH):$(CLIP_HEIGHT)

.PHONY: generate-all generate-gif wide set-wallpaper wallpapers compress prune $(SVG) $(WALLPAPERS)
generate-all:
	@$(MAKE) wallpapers
	@$(MAKE) compress
	@$(MAKE) generate-gif
	@$(MAKE) wide
generate-gif:
	@echo "Generating gifs..."
	@convert -delay 150 *.png +dither -alpha off -loop 0 docs/Wallpapers.gif
wide:
	@GENERATE_WIDE="true" $(MAKE) wallpapers
	@GENERATE_WIDE="true" $(MAKE) compress
set-wallpaper:
	@echo "Widescreen wallpapers:"
	@ls ./wide/*.png
	@echo -e "\nRegular wallpapers:"
	@ls ./*.png
	@echo -e "\nEnter the filename of the wallpaper to use:"
	@read -r wallpaper; if [[ -f "$$wallpaper" ]]; then \
	  mkdir -p ~/Pictures/Wallpapers; \
	  cp "$$wallpaper" ~/Pictures/Wallpapers; \
	  gsettings set org.gnome.desktop.background picture-uri "file:///home/$$USER/Pictures/Wallpapers/$${wallpaper##*/}"; \
	  gsettings set org.gnome.desktop.background picture-uri-dark "file:///home/$$USER/Pictures/Wallpapers/$${wallpaper##*/}"; \
	  gsettings set org.gnome.desktop.background picture-options 'zoom'; \
	else \
	  echo "Invalid filename"; \
	fi
wallpapers: prune
	@$(MAKE) $(SVG)
compress:
	@$(MAKE) $(WALLPAPERS)
prune:
	./clean-svgs.py
$(SVG):
	echo "Generating $(EXPORT_DIR)$@..."
	@svgFile="$@"; \
	inkscape "--export-png-color-mode=RGB_8" \
	         "--export-filename=$(EXPORT_DIR)$${svgFile/.svg/.png}" \
	         "--export-area=$(EXPORT_REGION)" \
	         "--export-width=$(EXPORT_WIDTH)" \
	         "--export-height=$(EXPORT_HEIGHT)" \
	         "$$svgFile" > /dev/null 2>&1
$(WALLPAPERS):
	@echo "Compressing $(EXPORT_DIR)$@..."
	@optipng -nc -strip all --quiet "$(EXPORT_DIR)$@"
