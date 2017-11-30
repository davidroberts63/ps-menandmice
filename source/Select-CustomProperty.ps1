function Select-CustomProperty {
    param (
        $name,
        [Parameter(ValueFromPipeline)]
        $inputObject
    )

    process {
        $property = $inputObject.customProperties | Where-Object name -eq $name
        if($property -and $property.value) {
            $property.value | Write-Output
        }
    }
}
