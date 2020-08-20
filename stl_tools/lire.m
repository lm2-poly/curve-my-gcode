function status = lire(fid,masque,debug)
% ================================================== 
% Lecture d'une ligne selon un masque
% Input: fid     Identificateur de fichier ouvert
%        masque  Chaine de caractères clef
%        debug   (true/false) Affichage détaillé
% Output: status (true/false) Ligne identique au masque
% ==================================================
  ligne=fgetl(fid);        % Lecture d'une ligne dans le fichier
  ligne=strtrim(ligne);
  status=true;
  if strcmp(ligne,masque)
    s =[masque,' -> OK'];
  else
    s =[masque,' -> Not OK'];
    if ligne(1)~='s' && ligne(1)~='e'
      status=false;
    end
  end
  if debug
    disp(s);
  end
end
