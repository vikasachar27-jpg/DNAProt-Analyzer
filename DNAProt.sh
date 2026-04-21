#!/bin/bash

# 1. Input Handling - Optimized for Gradio/Jupyter
# Instead of 'read', we take the filename as the first argument ($1)
filename=$1

if [ ! -f "$filename" ]; then
    echo "Error: File '$filename' not found!"
    exit 1
fi

# 2. Sequence Extraction and Cleaning
seq=$(grep -v "^>" "$filename" | tr -d '[:space:]\r' | tr '[:lower:]' '[:upper:]')
len=${#seq}

if [ "$len" -eq 0 ]; then
    echo "Error: No valid genetic sequence detected!"
    exit 1
fi

# 3. Translation Function (RNA -> Protein)
translate_rna() {
    local rna_seq=$1
    local protein=""
    for (( i=0; i<${#rna_seq}-2; i+=3 )); do
        codon=${rna_seq:$i:3}
        case $codon in
            AUG) aa="M";;
            UUU|UUC) aa="F";;
            UUA|UUG|CUU|CUC|CUA|CUG) aa="L";;
            AUU|AUC|AUA) aa="I";;
            GUA|GUC|GUU|GUG) aa="V";;
            UCU|UCC|UCA|UCG|AGU|AGC) aa="S";;
            CCU|CCC|CCA|CCG) aa="P";;
            ACU|ACC|ACA|ACG) aa="T";;
            GCU|GCC|GCA|GCG) aa="A";;
            UAU|UAC) aa="Y";;
            CAU|CAC) aa="H";;
            CAA|CAG) aa="Q";;
            AAU|AAC) aa="N";;
            AAA|AAG) aa="K";;
            GAU|GAC) aa="D";;
            GAA|GAG) aa="E";;
            UGU|UGC) aa="C";;
            UGG) aa="W";;
            CGU|CGC|CGA|CGG|AGA|AGG) aa="R";;
            GGU|GGC|GGA|GGG) aa="G";;
            UAA|UAG|UGA) aa="*";;
            *) aa="X";;
        esac
        protein+=$aa
    done
    echo "$protein"
}

# 4. Processing and Calculations
A=$(echo "$seq" | tr -cd 'A' | wc -c)
T=$(echo "$seq" | tr -cd 'T' | wc -c)
G=$(echo "$seq" | tr -cd 'G' | wc -c)
C=$(echo "$seq" | tr -cd 'C' | wc -c)

GC=$((G + C))
AT=$((A + T))
Purines=$((A + G))
Pyrimidines=$((C + T))
Tm=$(( (2 * AT) + (4 * GC) ))
cpg_count=$(echo "$seq" | grep -o "CG" | wc -l)

# Math via bc
GC_content=$(echo "scale=2; ($GC/$len)*100" | bc)
AT_content=$(echo "scale=2; ($AT/$len)*100" | bc)
Ratio=$(echo "scale=2; $Purines/$Pyrimidines" | bc)

# Transformations
rna=$(echo "$seq" | tr 'T' 'U')
rev_comp=$(echo "$seq" | rev | tr 'ATGC' 'TACG')
protein_seq=$(translate_rna "$rna")

# 5. Final Formatted Output
echo ""
echo "================ DNAProt Pro Analyzer ================"
echo "File Analyzed : $(basename "$filename")"
echo "Sequence Len  : $len bp"
echo "------------------------------------------------------"
echo "NUCLEOTIDE DISTRIBUTION"
echo "A: $A | T: $T | G: $G | C: $C"
echo "Purines: $Purines | Pyrimidines: $Pyrimidines"
echo "Pur/Pyr Ratio: $Ratio"
echo ""
echo "THERMAL & GENOMIC PROPERTIES"
echo "GC Content    : $GC_content %"
echo "AT Content    : $AT_content %"
echo "CpG Islands   : $cpg_count"
echo "Est. Tm       : $Tm °C (Wallace Rule)"
echo "------------------------------------------------------"
echo "TRANSFORMATIONS"
echo "Reverse Comp : ${rev_comp:0:50}..."
echo "RNA Sequence : ${rna:0:50}..."
echo ""
echo "PROTEIN TRANSLATION"
echo "$protein_seq"
echo "------------------------------------------------------"
echo "Note: '*' denotes Stop Codon. Analysis Complete."
echo "======================================================"
