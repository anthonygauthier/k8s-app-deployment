terraform {
    # S3 Bucket was created manually for the sake of the exercise
    backend "s3" {
        bucket = "app-tfstates"
        key = "eks.tfstate"
        region = "ca-central-1"
    }
}