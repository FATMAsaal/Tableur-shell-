#!/bin/bash




##***********************************
##                help
##***********************************
# INPUT :  rien
# OUTPUT : affichage des différentes options de la commande tableur
# RETURN : rien
function help
{

    echo "tableur   [-in feuille]   [-out  résultat]   [-scin sep]   [-scout  sep]   [-slin sep]   [-slout  sep]   [-inverse Les différentes options sont les suivantes, leur ordre d'apparition n'est pas et ne doit pas étre fixé."
    echo " -in feuille : permet d'indiquer dans quel fichier (feuille) se trouve la feuille de calculs. Si cette option n'est pas spécifiée sur la ligne de commande, la feuille de calculs sera lue depuis l'entrée standard."
    echo "- -out résultat : permet d'indiquer dans quel fichier (résultat) doit étre écrite la feuille calculée. Si cette option n'est pas spécifiée, le résultat sera affiché sur la sortie standard."
    echo "- -scin sep : permet de spécifier le séparateur (sep) de colonnes de la feuille de calculs initiale. Par défaut si cette option n'est pas spécifiée, ce séparateur est la tabulation."
    echo "- -slin sep : permet de spécifier le séparateur (sep) de lignes de la feuille de calculs initiale. Par défaut si cette option n'est pas spécifiée, ce séparateur est le RETURN chariot."
    echo "- -scout sep : permet de spécifier le séparateur (sep) de colonnes de la feuille calculée. Par défaut si cette option n'est pas spécifiée, ce séparateur est identique au séparateur de colonnes de la feuille de calculs initiale ;"
    echo "- -scout sep : permet de spécifier le séparateur (sep) de lignes de la feuille calculée. Par défaut si cette option n'est pas spécifiée, ce séparateur est identique au séparateur de lignes de la feuille de calculs initiale."
    echo "- -inverse : cette option provoque l'inversion lignes/colonnes de la feuille calculée."
}

##***********************************
##                ij
##***********************************
# IN : $1 est de la forme licj ou i et j st des nombres
# OUT : $i et $j
# RETURN : rien
function ij
{
    local i
    local j
    i=`echo $1 | cut -d c -f1 | cut -d l -f2`
    j=`echo $1 | cut -d c -f2 `
    echo $i $j
}

##***********************************
##               cel
##***********************************
# IN : $i et $j
# OUT : Affiche la cellule correspondant é $i$j
# RETURN : rien
function cel
{
    local i
    local j
    local saveIFS
    local sortie
    i=$1
    j=$2
    saveIFS=$IFS
    IFS=$slin
    set $fichier

    # Extraction de la ligne
    if [ $# -ge $i ]  # Nb de lignes OK
	then
    shift `expr $i - 1`
	IFS=$scin
  set $1

	# Extraction de la colone
	if [ $# -ge $j ] # Nb de colones OK
	    then
	    shift `expr $j - 1`
	    sortie=$1

	else
	    sortie="#ERREUR-Colone#"
	fi

    else
	sortie="#ERREUR-ligne#"
    fi

    IFS=$saveIFS
    echo $sortie
}

##***********************************
##                somme
##***********************************
# INPUT :  en entree il ya une liste de valeurs
# OUTPUT : en sortie la somme de tout les nombres passés en arguments
# RETOUR : rien
function somme
{
    local resultat
    resultat=0
    while test $# -ge 1
      do
      	  resultat=`echo "$resultat + $1" | bc -l`
      	  shift
    done
    echo "$resultat"
}


##***********************************
##                myenne
##***********************************
# INPUT :  ça prend deux cellules en intervalle
# OUTPUT : affiche la moyennes des toutes les cellules dans l'intervalle passé en paramètres
# RETOUR : rien
function moyenne
{
      # On doit avoir une sélection non nulle (division par zéro!!)
    if [ $# -eq 0 ]
    then
      echo "la séléction est nulle"
      # Si la séléction n'est pas nulle on divise la somme de tout les arguments sur le nombre d'éléments
    else
      echo "`somme $*` / $#" | bc -l
    fi
}

##***********************************
##                is_real
##***********************************
# INPUT :  une valeur numérique en sortie la somme de tout les nombres passés en arguments
# OUTPUT : affichage de la valeur réelle du nombre passé en paramètre
# RETOUR : rien
function is_real
{
    echo $1 | grep -q -E "^([\+\-])?[0-9]+([.]{1}[0-9]+)?$"
}


##***********************************
##                ecarttype
##***********************************
# INPUT :  prend deux cellules en paramètres
# OUTPUT : affiche l'écart type entre les deux cellules entrées en paramètres
# RETOUR : rien
function ecarttype
{
    test $# -ne 2 && echo "nombre d'arguments non correspondant" && return 0
    local card = 0 # on l'incrémente à chaque tour de boucle
    local moyenne = 0 #on rajoute les elements par accumulation et on dicise par le cardinal
    local ecart = 0 #on accumule la somme des différences entre moyenne et elt
    local l1 = `echo $1|cut -b 2`
    local c1 = `echo $1|cut -b 4`
    local l2 = `echo $2|cut -b 2`
    local c2 = `echo $2|cut -b 4`


    while `test $l1 < $l2 `
        do  while `test $c1 < $c2 `
            do  moyenne=`echo "$moyenne + ["l""$l1""c""$c1"]" | bc -l`
                card = `expr $card + 1`
                $c1 = `expr $c1 + 1 `
            done
        $l1 = `expr $l1 + 1`
        done
    $moyenne = `expr $moyenne / $card`

    local l1 = `echo $1|cut -b 2`
    local c1 = `echo $1|cut -b 4`

    while `test $l1 < $l2 `
        do  while `test $c1 < $c2 `
            do  ecart=`echo "$moyenne - ["l""$l1""c""$c1"]" | bc -l`
                $c1 = `expr $c1 + 1 `
            done
        $l1 = `expr $l1 + 1`
        done
    $ecart = `echo "$ecart / $card" | bc -l`
    echo "sqrt($ecart)" | bc -l

}

##***********************************
##                mediane
##***********************************
# INPUT :  prend deux cellules en paramètres
# OUTPUT : affiche la médiane calculée entre les deux cellules entrées en paramètre
# RETOUR : rien
function mediane
{
    test $# -ne 2 && echo "nombre d'arguments non correspondant" && return 0
    nominateur = `echo "[$1] + [$2]" | bc -l`
    echo "$nominateur / 2" | bc -l
}

##***********************************
##                min
##***********************************
# INPUT :  prend deux cellules en paramètres
# OUTPUT : affiche la plus petite valeur dans l'intervalle des cellules passées en paramètres
# RETOUR : rien
function min
{
    test $# -ne 2 && echo "nombre d'arguments non correspondant" && return 0
    local l1 = `echo $1|cut -b 2`
    local c1 = `echo $1|cut -b 4`
    local l2 = `echo $2|cut -b 2`
    local c2 = `echo $2|cut -b 4`
    local min



    while `test $l1 < $l2 `
        do  while `test $c1 < $c2 `
            do  elt = ["l""$l1""c""$c1"]
                if `test $elt -lt $min`
                    then $min = $elt
                fi
                $c1 = `expr $c1 + 1 `
            done
        $l1 = `expr $l1 + 1`
        done
    echo $min
}


##***********************************
##                max
##***********************************
# INPUT :  prend deux cellules en paramètres
# OUTPUT : affiche la plus grande valeur dans l'intervalle des cellules passées en paramètres
# RETOUR : rien
function max
{
    local l1 = `echo $1|cut -b 2`
    local c1 = `echo $1|cut -b 4`
    local l2 = `echo $2|cut -b 2`
    local c2 = `echo $2|cut -b 4`
    local max



    while `test $l1 -lt $l2 `
        do  while `test $c1 -lt $c2 `
            do  elt = ["l""$l1""c""$c1"]
                if `test $elt -gt $max`
                    then $max = $elt
                fi
                $c1 = `expr $c1 + 1 `
            done
        $l1 = `expr $l1 + 1`
        done
    echo $max
}


##***********************************
##                concat
##***********************************
# INPUT :  prend deux chaines de caractères
# OUTPUT : affiche la concaténation des deux chaines passées en paramètres
# RETOUR : rien
function concat
{
  test $# -ne 2 && echo "nombre d'arguments non correspondant" && return 0
  echo "$1""$2"
}

##***********************************
##                length
##***********************************
# INPUT :  prend une chaine de caractères
# OUTPUT : affiche la longueur de cette chaine
# RETOUR : rien
function length
{
  test $# -ne 2 && echo "nombre d'arguments non correspondant" && return 0
  echo ${#{$1}}
}


##***********************************
##                substitute
##***********************************
# INPUT :  prend trois chaines de caractères
# OUTPUT : affiche la substitution de la chaine3 avec la chaine2 dans la chaine1
# RETURN : rien
function substitute
{
  test $# -ne 3 && echo "nombre d'arguments non correspondant" && return 0
  echo  "'${1/"$2"/"$3"}'"
}

##***********************************
##                size
##***********************************
# INPUT :  prend un nom de fichier
# OUTPUT : affiche la taille du fichier passé en paramètre
# RETURN : rien
function size
{
  test $# -ne 1 && echo "nombre d'arguments non correspondant" && return 0
  echo `ls -lh  "$1"| cut -d " " -f5`
}


##***********************************
##                lines
##***********************************
# INPUT :  prend un nom de fichier
# OUTPUT : retourne le nombre de lignes du fichier passé en paramètre
# RETURN : rien
function lines
{
  test $# -ne 1 && echo "nombre d'arguments non correspondant" && return 0
  echo `cat $1 | wc -l`
}

##***********************************
##                shell
##***********************************
# INPUT :  prend une chaine de caractères comportant une commande shell
# OUTPUT : retourne le résultat de la commande passée en paramètre
# RETURN : rien
function shell
{
  test $# -ne 1 && echo "nombre d'arguments non correspondant" && return 0
  echo `$1`
}


##***********************************
##                display
##***********************************
# INPUT :  prend deux cellules en intervalle
# OUTPUT : rien (enregistre le résultat de sortie dans une variable)
# RETURN : rien
function display
{
    test $# -ne 2 && echo "nombre d'arguments non correspondant" && return 0
    local cases_actives=""
    local l1 = `echo $1|cut -b 2`
    local c1 = `echo $1|cut -b 4`
    local l2 = `echo $2|cut -b 2`
    local c2 = `echo $2|cut -b 4`

    while `test $l1 -lt $l2 `
    do  while `test $c1 -lt $c2 `
        do  $caes_actives = "$cases_actives""["l""$l1""c""$c1"]"
            $c1 = `expr $c1 + 1 `
        done
    $l1 = `expr $l1 + 1`
    done
    $sortie = "$sortie" "$cases_actives"
}


##***********************************
##                parcours
##***********************************
# INPUT :  rien
# OUTPUT : rien (enregistre l'affichage du résultat de sortie dans la variable de sortie
# RETURN : rien

function parcours
{
  local nbLignes=0
  local nbColonnes=0
  local nbCases=0
  local cpt=0
  local nc=1
  local nl=1
  local l

  local oldIFS=$IFS # sauvegarde du séparateur de champ
  IFS = "$slin" #changement de la velur de l'IFS, le séparateur de lignes est maintenant reconnu comme séparateur dans le shell

  # récupérer le nombre de lignes, de colonnes et de cases pour pouvoir parcourir les éléments du tableau
  for line in $entree
  do
    nbLignes=`expr $nbLignes + 1`
  done
  IFS = $IFS"$scin"
  for element in $entree
  do
    nbCases=`expr $nbCases + 1`
  done
  nbColonnes=`expr $nbCases / $nbLignes`


  # affichage de la numérotation des colonnes
  nc=1
  while `test $nc -ne $nbColonnes`
    do sortie=$sortie$nc
        nc=`expr $nc - 1`
  done
  sortie=$sortie" "$nl

# parcours des éléments du tableau et affichage de la numérotation des lignes
  for i in $entree
  do
    l=`expr cpt % nbLignes`
    if `test $l -eq 0`
    then sortie = $sortie$slout
      if `test $cpt -ne $nbCases`
        then nl=`expr $nl + 1`
             sortie=$sortie" "$nl
      fi
    else
       if `test $i = "="`
          then case ($(i+1))
                "+") +();;
                "-") -();;
                "*") *();;
                "/") /();;
                "^") ^();;
                "ln") ln();;
                "e") e();;
                "sqrt") sqrt();;
                "somme") somme();;
                "moyenne") moyenne();;
                "variance") variance();;
                "ecarttype") ecarttype();;
                "mediane") mediane();;
                "min") min();;
                "concat") concat();;
                "length") length();;
                "subsitute") substitute();;
                "size") size();;
                "lines") lines();;
                "shell") shell();;
                "display") display();;
                *) echo "Cette fonction n'est pas définie!"
              esac
            else
              sortie=$sortie$i
            fi
            sortie=$sortie$scout
        fi
    cpt=`expr $cpt + 1`
  done
  IFS = $oldIFS
}








# déclarations initiales
bool_in=1
bool_out=1
nbLignes=0
nbColonnes=0
entree = ''
sortie = ''
scin = " "
slin = " "
scout = $scin
slout = $slin

# boucle principale
for i in $@
  do case "$i" in
    "--help") help()
              break;;
    "-in") bool=1
        $i=($(i+1))
        for j in `ls *.txt`
            do if (`expr "$j" -eq "$i"`)
                then entree=`cat "$j"`;
                     bool_in=0
                fi
            done

        if (`test $bool_in -eq 1`)
        then echo "File not found."
        fi;;


    "-out") bool_out=1
         $i=($(i+1));
         for j in `ls *.txt`
             do if (`expr "$j" -eq "$i"`)
                 then parcours()
                      echo sortie > "$j";
                      bool_out=0
                fi
             done
         if (`test $bool -eq 1`)
         then echo "File not found."
    "-scin") scin = ($(i+1));;
    "-scout") scout = ($(i+1));;
    "-slin") slin = ($(i+1));;
    "-slout") slout = ($(i+1));;
    "inverse");; #inverser les var de sep, les boucles de parcours et les cili en lici
    *) if (`test $bool_in -eq 1`)
        then read entree
    fi
    if (`test $bool_out -eq 1`)
        then sortie()
        echo $sortie
    fi
esac
