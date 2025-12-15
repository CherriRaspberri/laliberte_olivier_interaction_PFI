# laliberte_olivier_interaction_PFI
Projet final pour le cours d'interaction ludique au collège Montmorency.\
Lien vers le jeu [ici](https://cherriraspberri.github.io/laliberte_olivier_interaction_PFI/).\
Lien vers la page itch.io [ici](https://cherriraspberri.itch.io/space-race).

## CONCEPT 
Jeu de shmup pseudo-infini en vue top-down. Dépendant du niveau, il faut soit atteindre un certain score, tuer un ennemi ou attendre la fin d'un timer.\

## NIVEAUX
### Niveau 1 :
But : Atteindre 3000pts.\
Niveau schmup de base. Incrémentation de difficulté après chaque tranche de 1000pts amassés.

### Niveau 2 :
But : Tuer un ennemi.\
Niveau mini-boss. Incrémentation de difficulté après que la moitié de la vie de l'ennemi soit enlevée.

### Niveau 3 :
But : Survivre 1min.\
Niveau de survie de base. Incrémentation de difficulté après chaque tranche de 15sec passée.

## PLAYER
### Attributs :
Le joueur est muni d'un vaisseau pouvant naviguer de gauche à droite. Les assets du jeu donnent l'illusion que le vaisseau avance en continu.\
Le joueur est aussi muni d'un canon laser. Le canon tire en ligne droite vers le haut.

### Contrôles :
A : bouger à gauche.\
W : bouger à droite.\
Spacebar : tirer un laser.

## COMÈTES 
Les comètes sont des obstacles présents pour le joueur. Le joueur peut tirer dessus pour augmenter son score.\
Il existe 2 types de comètes : grandes et petites.\
Grandes : 100pts.\
Petites : 250pts.\
Les petites comètes rapportent plus de pts, vu qu'elles sont plus difficiles à tirer.

### Murs 
Les murs (positionnés à gauche et à droites du niveau) sont hostiles; Le joueur peut entrer en collision avec. Considérés commes ennemis ne pouvant pas se détruire.

## ENNEMI
L'ennemi est un mini-boss pour le joueur. Le joueur peut tirer dessus pour réduire la vie de celui-ci.\
Vie : 30HP.\
L'ennemi vise en tout temps le joueur. Quand le joueur est assez proche, l'ennemi va tirer dessus à une vitesse constante.\
Phase 01 : 1 seconde de cooldown.\
Phase 02 : 0.5 seconde de cooldown.

### Mouvement 
Le mouvement de l'ennemi est prédéfini et est en forme d'un 8 allongé horizontalement. L'ennemi va toujours bouger sur ce chemin, et ne va jamais se déplacer hos de celui-ci.

## UI
UI simple qui affiche un traqueur de score.\
Pour les niveaux avec un ennemi, un traqueur de vie est affiché au dessus de l'ennemi.\
Pour les niveaux avec un timer, un traqueur de temps est affiché.

### Avertissements :
Au début de chaque niveau, une alerte indiquant dans quel niveau le joueur se retrouve est affichée.\
Chaque fois qu'une augmentation de la difficulté est effectuée, un message s'affiche pour l'indiquer au joueur.\
Quand le joueur se fait heurter par une comète, un message "GAME OVER" s'affiche.\
Quand le joueur complète un niveau ou le jeu, un message d'achèvement s'affiche.
