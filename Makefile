run.macos:
	cargo build --manifest-path native/Cargo.toml && \
	mkdir -p macos/lib && \
	cp -f native/target/debug/libnative.dylib macos/lib/libnative.dylib && \
	cd example && \
	flutter pub get && \
	flutter run -d macos

run.linux:
	cargo build --manifest-path native/Cargo.toml && \
	mkdir -p linux/lib && \
	cp -f native/target/debug/libnative.so linux/lib/libnative.so && \
	cd example && \
	flutter pub get && \
	flutter run -d linux



.PHONY: run.macos run.linux
