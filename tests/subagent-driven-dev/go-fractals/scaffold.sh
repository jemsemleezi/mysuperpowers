#!/usr/bin/env bash
# Scaffold a Go fractals project for testing subagent-driven-development
# Usage: ./scaffold.sh <output-dir>

set -e

OUTPUT_DIR="${1:?Usage: $0 <output-dir>}"
mkdir -p "$OUTPUT_DIR"

echo ">>> Scaffolding Go Fractals project in $OUTPUT_DIR..."

# Initialize Go module
cd "$OUTPUT_DIR"
go mod init fractals 2>/dev/null || true

# Create main.go
cat > main.go <<'EOF'
package main

import (
	"fmt"
	"image"
	"image/color"
	"image/png"
	"os"
)

// FractalRenderer renders mathematical fractals
type FractalRenderer interface {
	Render(width, height int) *image.RGBA
}

// MandelbrotRenderer renders the Mandelbrot set
type MandelbrotRenderer struct {
	maxIter int
}

// JuliaRenderer renders Julia sets
type JuliaRenderer struct {
	c       complex128
	maxIter int
}

func main() {
	fmt.Println("Fractal Generator")
	fmt.Println("Usage: go run main.go <mandelbrot|julia> <output.png>")
}
EOF

# Create plan.md for subagent execution
cat > plan.md <<'EOF'
# Fractals Implementation Plan

## Task 1: Implement Mandelbrot Set

Implement the Mandelbrot set renderer.

**File:** `mandelbrot.go`

**Implementation:**
- Create `MandelbrotRenderer` struct with `maxIter` field
- Implement `Render(width, height int) *image.RGBA` method
- Use standard Mandelbrot escape-time algorithm
- Map complex plane coordinates to pixel coordinates
- Color pixels based on iteration count

**Tests:** Write tests in `mandelbrot_test.go`:
- Test that Render returns correct image dimensions
- Test that known points are in/out of the set
- Test edge cases (max iterations)

**Verification:** `go test ./...`

## Task 2: Implement Julia Set

Implement the Julia set renderer.

**File:** `julia.go`

**Implementation:**
- Create `JuliaRenderer` struct with `c` (complex parameter) and `maxIter` fields
- Implement `Render(width, height int) *image.RGBA` method
- Allow different Julia set parameters
- Add color gradient based on escape time

**Tests:** Write tests in `julia_test.go`:
- Test Julia set rendering with known parameters
- Test that different parameters produce different outputs
- Test image properties

**Verification:** `go test ./...`

## Task 3: Add CLI and Image Output

Add command-line interface and PNG output.

**File:** `main.go` (update)

**Implementation:**
- Parse command-line arguments for fractal type and output file
- Support both Mandelbrot and Julia sets
- Save rendered image as PNG
- Add help text and usage examples

**Tests:** Update tests to verify CLI behavior

**Verification:** `go build -o fractals . && ./fractals`
EOF

echo ">>> Go Fractals project scaffolded successfully"
echo "  Plan: $OUTPUT_DIR/plan.md"
echo "  Main: $OUTPUT_DIR/main.go"
