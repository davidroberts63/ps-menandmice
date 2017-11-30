function Find-HavingCustomProperty {
    param (
        $name,
        $value,
        [Parameter(ValueFromPipeline)]
        $inputObject
    )

    process {
        $property = $inputObject.customProperties | Where-Object name -eq $name
        if($property -and $property.value -eq $value) {
            $inputObject | Write-Output
        }
    }
}
