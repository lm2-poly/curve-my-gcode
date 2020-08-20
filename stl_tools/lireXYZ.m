function vecteur = lireXYZ(fid,masque,debug)
% ==================================================
% Lecture d'une ligne selon un masque et vecteur
% Input: fid     Identificateur de fichier ouvert
%        masque  Chaine de caractères clef
%        debug   (true/false) Affichage détaillé
% Output: vecteur coordonnées X, Y et Z (vecteur ligne)
%         vecteur zéro s'il y a une erreur
% ==================================================
  ligne=fgetl(fid);        % Lecture d'une ligne dans le fichier
  [n,m]=size(ligne);
  [o,n]=size(masque);      % Nombre de caractère dans le masque
  ligne1=ligne(1:n);       % Partie 1 doit être identique au masque
  ligne2=ligne(n+1:m);     % Partie 2 contient X Y Z
  if strcmp(ligne1,masque)
	s=[masque,' -> OK'];
    vecteur=str2num(ligne2);
  else
    s=[masque,' -> Not OK'];  
    vecteur=[0, 0, 0];     % Un vecteur zéro indique une erreur
  end
  if debug
    disp(s);
  end
end
