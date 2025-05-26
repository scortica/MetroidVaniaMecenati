PLAYER
• Gestione parry collision ✓
• Fix attack collision X (ATTENDERE ANIMAZIONI)
• Logica di HP 5/6 vite ✓
      - Danno toglie 1 vita ✓
      - Morte quando vite vanno a 0 X (AGGIUNGERE POSSIBILITÀ DI RESPAWN CON TASTO)
      - Cura consuma 4 barre croce X (AGGIUNGERE TASTO PER CURARSI E ANIMAZIONE)

ENEMY_GHOST
• Fix collision Box fissate sullo sprite X(MODIFICARE CON SPRITE NUOVO)
• Logica di movimento (fluttua seguendo il player potendo passare attraverso piattaforme) X(PRENDERE DA VECCHIO PROGETTO)
• Logica HP✓
        - DANNO✓
        - MORTE X(ANIMAZIONE)

ENEMY_SHOOTER
• Fix collision Box fissate sullo sprite ✓
• Logica di movimento (NON SI MUOVE RUOTA SOLO VERSO IL PLAYER QUANDO LO SPOTTA) ✓
• Logica HP ✓
     - DANNO ✓
     - MORTE X(ANIMAZIONE)
• Logica attacco (spara 1 colpo alla volta e attende N secondi per poterne sparare un altro) ✓

BOSS
• Manco simone sa come è fatto quindi boh

BULLET
• Viene creato sull'enemy_shooter usando l'angolo tra enemy_shooter e player. Si muove verso il player con velocità speed, entrato nella parry collision se si preme il tasto destro del mouse il proiettile si ribalta(angolo - pi) e viaggia a velocità -speed, gli viene applicata la classe collision parried_bullet e rimossa la classe enemyAttack (per permettere al proiettile dincolpire il nemico), se entra nella collision box del nemico che ha sparato o di qualunque nemico si metta in mezzo esso subisce danni. Se il proiettile sparato dal nemico entra nella collision box del player esso subisce danni. Dopo aver colpito qualcosa o aver hittato il terreno il proiettile viene distrutto. X (Manca distruzione sulla collisione col suolo)

OPZIONALE FIGO MA BOH NON CI STA TEMPO CREDO

    • Hit stop sull'attacco del player con shake della telecamera.
    • Telecamera non fissa sul player ma che lo segue lentamente 
    • Parallasse background per effetto profondità migliore
    • Shader (nebbia + illuminazione)



HUD
• Croce si carica ad ogni hit/parry (poi si decide) 16 cariche ne consumi 4 per 1 cura X (VA AGGIUNTA GRAFICAMENTE CON ANIMAZIONI)
• Vita definita da 5/6 boccette che sono scariche/cariche e hanno animazione di scarica e carica X ( VA AGGIUNTA GRAFICAMENTE)