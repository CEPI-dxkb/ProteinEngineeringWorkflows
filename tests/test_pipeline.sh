#!/bin/bash
# Test script for Protein Engineering Workflows
#
# Usage:
#   ./test_pipeline.sh [--quick]     # Quick validation only
#   ./test_pipeline.sh               # Full test with structure prediction

set -e
cd "$(dirname "$0")/.."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

QUICK_MODE=false
PASSED=0
FAILED=0
SKIPPED=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            QUICK_MODE=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Helper functions
info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAILED=$((FAILED + 1))
}

skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
    SKIPPED=$((SKIPPED + 1))
}

section() {
    echo ""
    echo "========================================"
    echo "$1"
    echo "========================================"
}

#======================================
# Pre-requisite Checks
#======================================
section "Pre-requisite Checks"

# Check cwltool
if command -v cwltool &> /dev/null; then
    VERSION=$(cwltool --version 2>&1 | head -1)
    pass "cwltool installed: $VERSION"
else
    fail "cwltool not installed"
    echo "Install with: pip install cwltool"
    exit 1
fi

# Check Docker
if command -v docker &> /dev/null; then
    pass "Docker installed"
else
    fail "Docker not installed"
    exit 1
fi

# Check Docker daemon
if docker info &> /dev/null; then
    pass "Docker daemon running"
else
    fail "Docker daemon not running"
    exit 1
fi

#======================================
# CWL Validation
#======================================
section "CWL Validation"

# Validate tool definitions
for tool in cwl/tools/*.cwl; do
    if cwltool --validate "$tool" &> /dev/null; then
        pass "Valid: $tool"
    else
        fail "Invalid: $tool"
        cwltool --validate "$tool"
    fi
done

# Validate workflow definitions
for workflow in cwl/workflows/*.cwl; do
    if cwltool --validate "$workflow" &> /dev/null; then
        pass "Valid: $workflow"
    else
        fail "Invalid: $workflow"
        cwltool --validate "$workflow"
    fi
done

#======================================
# Example Job Validation
#======================================
section "Example Job Validation"

# Check that example job files exist and are valid YAML
for job in examples/*.yml; do
    if python3 -c "import yaml; yaml.safe_load(open('$job'))" &> /dev/null; then
        pass "Valid YAML: $job"
    else
        fail "Invalid YAML: $job"
    fi
done

# Check that referenced sequence files exist
for job in examples/*.yml; do
    SEQ_FILE=$(grep -A1 "sequence_file:" "$job" | grep "path:" | awk '{print $2}')
    if [ -n "$SEQ_FILE" ]; then
        FULL_PATH="examples/$SEQ_FILE"
        if [ -f "$FULL_PATH" ]; then
            pass "Sequence file exists: $FULL_PATH"
        else
            fail "Sequence file missing: $FULL_PATH"
        fi
    fi
done

#======================================
# Docker Image Checks
#======================================
section "Docker Image Checks"

check_image() {
    local image=$1
    if docker image inspect "$image" &> /dev/null; then
        pass "Image available: $image"
        return 0
    else
        skip "Image not available: $image (pull with: docker pull $image)"
        return 1
    fi
}

BOLTZ_AVAILABLE=$(check_image "dxkb/boltz-bvbrc:latest-gpu" && echo "yes" || echo "no")
CHAI_AVAILABLE=$(check_image "dxkb/chai-bvbrc:latest-gpu" && echo "yes" || echo "no")
STAB_AVAILABLE=$(check_image "dxkb/stabilinnator-bvbrc:latest-gpu" && echo "yes" || echo "no")

#======================================
# Quick Mode Summary
#======================================
if [ "$QUICK_MODE" = true ]; then
    section "Quick Mode Summary"
    echo "CWL validation: Complete"
    echo "Example validation: Complete"
    echo ""
    echo "To run full tests with structure prediction:"
    echo "  ./test_pipeline.sh"
    echo ""

    section "Test Summary"
    echo -e "Passed:  ${GREEN}$PASSED${NC}"
    echo -e "Failed:  ${RED}$FAILED${NC}"
    echo -e "Skipped: ${YELLOW}$SKIPPED${NC}"

    if [ $FAILED -gt 0 ]; then
        exit 1
    fi
    exit 0
fi

#======================================
# Full Pipeline Test
#======================================
section "Full Pipeline Test"

if [ "$STAB_AVAILABLE" = "no" ]; then
    skip "Full pipeline test (stabiliNNator image not available)"
elif [ "$BOLTZ_AVAILABLE" = "no" ] && [ "$CHAI_AVAILABLE" = "no" ]; then
    skip "Full pipeline test (no structure prediction image available)"
else
    # Create temporary output directory
    TEST_OUTPUT=$(mktemp -d)
    info "Test output directory: $TEST_OUTPUT"

    # Test with smallest example (crambin)
    if [ "$BOLTZ_AVAILABLE" = "yes" ]; then
        info "Running Boltz pipeline with crambin..."

        if cwltool \
            --outdir "$TEST_OUTPUT/boltz" \
            cwl/workflows/protein_stability_pipeline.cwl \
            examples/crambin_job.yml; then
            pass "Boltz pipeline completed"

            # Check outputs
            if [ -f "$TEST_OUTPUT/boltz"/*_annotated.pdb ]; then
                pass "Annotated structure generated"
            else
                fail "Annotated structure not found"
            fi
        else
            fail "Boltz pipeline failed"
        fi
    fi

    if [ "$CHAI_AVAILABLE" = "yes" ]; then
        info "Running Chai-1 pipeline with crambin..."

        if cwltool \
            --outdir "$TEST_OUTPUT/chai" \
            cwl/workflows/protein_stability_with_chai.cwl \
            examples/crambin_fasta_job.yml; then
            pass "Chai-1 pipeline completed"
        else
            fail "Chai-1 pipeline failed"
        fi
    fi

    # Cleanup
    info "Cleaning up test outputs..."
    rm -rf "$TEST_OUTPUT"
fi

#======================================
# Test Summary
#======================================
section "Test Summary"
echo -e "Passed:  ${GREEN}$PASSED${NC}"
echo -e "Failed:  ${RED}$FAILED${NC}"
echo -e "Skipped: ${YELLOW}$SKIPPED${NC}"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
exit 0
