##################################################################################################################################
#	Dominik Bauer, 
#	use:
#	make 			build the sheet
#	make draft		build an draft version of the sheet
#	make clean		clean the messy stuff
#	make count		count words, merge include files
#	make resize		compress the pdf to 300dpi
#	make resize_minimal	compress to minimal dpi
#	make lua		build the sheet with lualatex
#	make beam		start okular in presentation mode (for example beamer.pdf) 
##################################################################################################################################
#	To-Do:
#	make svn_ci		commit to svn repo (git?) --> Backup 
#  inkscape -D -z --file=versuchsaufbau2.svg --export-pdf=image.pdf --export-latex
##################################################################################################################################


####################################
#       PROJECT
###################################
PROJECT=thesis


####################################
#       SETTINGS
###################################
OUTPUTDIR=.out
SHELL=/bin/bash


####################################
#       EXECTUABLE
###################################
TEX=lualatex
BIBER=biber
GHOSTSCRIPT=gs
LUALATEX=lualatex
OKULAR=okular
GLOSSARIES=makeglossaries
TEXCOUNT=./misc/texcount.pl

####################################
#       COLORS
###################################
NO_COLOR=\e[0m
OK_COLOR=\e[32;01m
ERROR_COLOR=\e[31;01m
WARN_COLOR=\e[33;01m
RUN_COLOR=\e[1;34m

####################################
#       FLAGS
###################################
#Tex Flags
TFLAGS+=--output-directory=$(OUTPUTDIR)
TFLAGS+=--shell-escape
#TFLAGS+=--interaction=nonstopmode
TFLAGS+=--file-line-error

#Biber Flags
BFLAGS+=--output_directory $(OUTPUTDIR)
BFLAGS+=

#Ghostscript Flags
GFLAGS+=-dNOPAUSE
GFLAGS+=-dBATCH 
GFLAGS+=-dDownsampleColorImages=true 
GFLAGS+=-dColorImageResolution=300
GFLAGS+=-dDownsampleGrayImages=true 
GFLAGS+=-dGrayImageResolution=300
GFLAGS+=-dDownsampleMonoImages=true 
GFLAGS+=-dMonoImageResolution=300
GFLAGS+=-sDEVICE=pdfwrite 
GFLAGS+=-sOutputFile=$(PROJECT)_resize.pdf 

#LuaLates Flags
LFLAGS+=-synctex=1
LFLAGS+=-interaction=nonstopmode
LFLAGS+=-output-directory=$(OUTPUTDIR) 
LFLAGS+=--shell-escape


#texcount Flags
TXFLAGS+=-inc
TXFLAGS+=-v0
TXFLAGS+=-auxdir=.$(OUTPUTDIR) 
TXFLAGS+=-relaxed

#Okular Flags
OFLAGS+=--presentation

#Glossaries Flags
GLFLAGS+=-d $(OUTPUTDIR)

#RM Flags
RMFLAGS+=-rf

#Grep-Flags
GRFLAGS+=-A 8 
GRFLAGS+=--color=always
GRFLAGS+=-i
TEXSEARCH+=".*:[0-9]*:.*\|warning"

#sed Flags
SFLAGS+=-e
BWARNSEARCH+="s/^WARN/\x1b[33;01m&\x1b[0m/" 
BERRSEARCH+="s/^ERROR/\x1b[31;01m&\x1b[0m/"
BINFOSEARCH+="s/^INFO/\x1b[32;01m&\x1b[0m/"

#Draft Flags
DFLAGS+="\def\isdraft{1} \input{$(PROJECT).tex}"

####################################
#      EXE 
##################################
BUILDTEX1		=$(TEX) $(TFLAGS) -draftmode $(PROJECT).tex
#| grep $(GRFLAGS) $(TEXSEARCH)
BUILDBIBER		=$(BIBER) $(BFLAGS) $(PROJECT) 	 | sed $(SFLAGS) $(BWARNSEARCH) \
												 | sed $(SFLAGS) $(BERRSEARCH)  \
												 | sed $(SFLAGS) $(BINFOSEARCH)

BUILDTEX		=$(TEX) $(TFLAGS) $(PROJECT).tex
#| grep $(GRFLAGS) $(TEXSEARCH)
BUILDLUA		=$(LUALATEX) $(PROJECT).tex
BUILDOKULAR		=$(OKULAR) $(PROJECT).pdf $(OFLAGS)
BUILDDRAFT		=$(TEX) $(TFLAGS) $(DFLAGS) 
#| grep $(GRFLAGS) $(TEXSEARCH)
BUILDRESIZE		=$(GHOSTSCRIPT) $(GFLAGS) $(PROJECT).pdf
BUILDGLOSSARIES	=$(GLOSSARIES) $(GLFLAGS) $(PROJECT)
BUILDCOUNT		=$(TEXCOUNT) $(TXFLAGS) $(PROJECT).tex 
COPY			=cp $(OUTPUTDIR)/$(PROJECT).pdf . \
						&& printf "$(RUN_COLOR)[$@]\t\t$(NO_COLOR) $(OK_COLOR) Copy $(PROJECT).pdf from $(OUTPUTDIR) to workdir$(NO_COLOR)\n";
####################################
#       PHONY
###################################
.PHONY: clean
.PHONY: clean-all
.PHONY: draft
.PHONY: count
.PHONY: glossaries
.PHONY: checkdir


####################################
#       SILENT MODE
###################################
.SILENT:
####################################
#       RULES
###################################
all: clean-all checkdir
		@printf "$(RUN_COLOR)[TeX]\t\t$(NO_COLOR) $(OK_COLOR) Building TeX files in final mode (1st run)$(NO_COLOR)\n";
		$(BUILDTEX1)
		#@printf "$(RUN_COLOR)[makeglossaries]\t$(NO_COLOR) $(OK_COLOR) Building glossaries $(NO_COLOR)\n";
		#$(BUILDGLOSSARIES)
		@printf "$(RUN_COLOR)[Biber]\t$(NO_COLOR) $(OK_COLOR) Creating BibTeX entries $(NO_COLOR)\n"; 
		$(BUILDBIBER)
		@printf "$(RUN_COLOR)[TeX]\t\t$(NO_COLOR) $(OK_COLOR) Building TeX files in final mode (2nd run)$(NO_COLOR)\n";
		$(BUILDTEX1)
		@printf "$(RUN_COLOR)[TeX]\t\t$(NO_COLOR) $(OK_COLOR) Building TeX files in final mode (3nd run)$(NO_COLOR)\n";
		$(BUILDTEX)
		$(COPY)

draft: checkdir
		@printf "$(RUN_COLOR)[$@]\t\t$(NO_COLOR) $(OK_COLOR) Building TeX files in draft mode $(NO_COLOR)\n";
		$(BUILDDRAFT)
		@printf "$(WARN_COLOR)[$@]\t\t$(NO_COLOR) $(WARN_COLOR) Draft mode: Bibliographie, glossaries and page numbers \
may not be updated!!! $(NO_COLOR)\n";
		$(COPY)

glossaries:
		@printf "$(RUN_COLOR)[$@]\t\t$(NO_COLOR) $(OK_COLOR) Building glossaries $(NO_COLOR)\n";
		$(BUILDGLOSSARIES)

clean-all:
	find . -type f -name "*.aux" -exec rm -rf {} \;
	find . -type f -name "*.log" -exec rm -rf {} \;
	find . -type f -name "*.bak" -exec rm -rf {} \;
	find . -type f -name "*.bbl" -exec rm -rf {} \;
	find . -type f -name "*.blg" -exec rm -rf {} \;
	find . -type f -name "*.idx" -exec rm -rf {} \;
	find . -type f -name "*.toc" -exec rm -rf {} \;
	find . -type f -name "*.out" -exec rm -rf {} \;
	find . -type f -name "*.upa" -exec rm -rf {} \;
	find . -type f -name "*.tex~" -exec rm -rf {} \;

clean:
		@printf "$(RUN_COLOR)[$@]\t\t$(NO_COLOR) $(ERROR_COLOR) Removing old files in $(OUTPUTDIR)$(NO_COLOR)\n";
		rm $(RMFLAGS) $(OUTPUTDIR)/*

count:
		@printf "$(RUN_COLOR)[$@]\t\t$(NO_COLOR) $(OK_COLOR) Count words in $(PROJECT).tex $(NO_COLOR)\n";
		$(BUILDCOUNT) 
resize:
		@printf "$(RUN_COLOR)[$@]\t\t$(NO_COLOR) $(OK_COLOR) Resize document to 300dpi $(NO_COLOR)\n";
		$(BUILDRESIZE) 
resize_minimal:
		$(GHOSTSCRIPT) -dNOPAUSE -dBATCH -dDownsampleColorImages=true -dColorImageResolution=75\
	       		-dDownsampleGrayImages=true -dGrayImageResolution=75\
		       	-dDownsampleMonoImages=true -dMonoImageResolution=75\
		       	-sDEVICE=pdfwrite -sOutputFile=$(PROJECT)_minimal.pdf $(PROJECT).pdf


lua:
		@printf "$(RUN_COLOR)[$@]\t\t$(NO_COLOR) $(OK_COLOR) Building Tex files with LuaLatex $(NO_COLOR)\n";
		$(BUILDLUA)

beam:
		@printf "$(RUN_COLOR)[$@]\t\t$(NO_COLOR) $(OK_COLOR) Starting $(OKULAR) in presentation mode $(NO_COLOR)\n";
		$(BUILDOKULAR) 
checkdir:
		@printf "$(RUN_COLOR)[$@]\t$(NO_COLOR) $(OK_COLOR) Checking directory $(NO_COLOR)\n";
		if [ ! -d "./$(OUTPUTDIR)" ];then\
			mkdir $(OUTPUTDIR);\
			printf "$(RUN_COLOR)[$@]\t$(NO_COLOR) $(WARN_COLOR) Creating output directory$(NO_COLOR)\n";\
		fi
#EOF
