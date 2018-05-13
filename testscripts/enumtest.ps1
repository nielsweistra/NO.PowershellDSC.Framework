Enum Fruit

{

 Apple = 29

 Pear = 30

 Kiwi = 31

}

$test = "Apple"
$pear = "Pear"
[Fruit]::Apple.GetHashCode()
[Fruit]::$pear.GetHashCode()
[Fruit].GetEnumNames()
[Fruit].get
[Fruit].GetEnumValues()
[enum]::GetNames([Fruit])
[Fruit]29
$answer = 31
[Fruit] $answer