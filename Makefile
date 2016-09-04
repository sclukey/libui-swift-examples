
.PHONY: build clean

build: clean
	swift build -Xlinker -L/opt/local/lib

clean:
	swift build --clean

