module load CBI bcftools
module load CBI r

vcfDir=$1
workDir=$2

nameVcf=$vcfDir"*vcf.gz"

cd $vcfDir
ls *vcf.gz > list_vcf.txt

for tempvcf in $(cat list_vcf.txt)
do
tabix $tempvcf
done

cd $workDir
ln -s $nameVcf .
ln -s $nameVcf".tbi" .

ls *vcf.gz > list_vcf.txt

for tempvcf in $(cat list_vcf.txt)
do
tempname1=${tempvcf%%.*}
tempname2=$tempname1"_228snps.vcf.gz"
tempname3="Geno_"$tempname1"_228snps.vcf"
tempname4="Missingness_"$tempname1
bcftools view -R snps_228.bed $tempvcf -o ${tempname2}
bcftools query -f '%CHROM %POS %ID %REF %ALT [ %GT]\n' $tempname2 -o ${tempname3}
tabix $tempname2
plink --const-fid --vcf $tempname2 --missing --out ${tempname4}
done

ls Missingness_*imiss > list_imiss.txt

ls Geno* > list_geno.txt
R CMD BATCH r_QC_vcf_v4.txt

ls Geno*clean.vcf > list_geno_clean.txt
R CMD BATCH r_LR_Genotypes_Ziv_Multi_Pop_vcf_v4.txt

