PRINT "+---------------------------------------------+"
PRINT "|              AutoCentering                  |"
PRINT "| https://github.com/mikhail-rodin/OpticGOST  |"
PRINT "+---------------------------------------------+"
PRINT

INPUT "Enter default decenter tolerance in um for lenses that cannot be autocentered: ", c_default

sfr_count = NSUR()
element = 0
radial_gap = 0.15
flat_max_curv = 1e-5
PRINT "+---------+---------+-----------------+------------------+"
PRINT "| Element | Surface | Centering Angle | Decenter, c, um  |"
PRINT "+---------+---------+-----------------+------------------+"
FOR srf, 1, sfr_count, 1
    IF (GIND(srf) > 1.01) 
        element = element + 1
        FORMAT "%#3i" LIT
        out$ ="|     " + $STR(element) + " | " + $STR(srf) + "-" + $STR(srf+1) + " |"
        c = c_default/1000
        flat1 = 0
        flat2 = 0
        doublet = 0
        IF (GIND(srf+1) > 1.01) THEN doublet = 1
        cv1 = CURV(srf)
        cv2 = CURV(srf+1)
        IF (ABSO(cv1) < flat_max_curv) THEN flat1 = 1
        IF (ABSO(cv2) < flat_max_curv) THEN flat2 = 1
        IF flat1 | flat2
            out$ = out$ + "  -Flat surface- |                  |" 
        ELSE
            sd1 = SDIA(srf)
            sd2 = SDIA(srf+1)
            r1 = 1/cv1
            r2 = 1/cv2
            IF r1*r2 > 0 
                meniscus = 1 
                phi_min = 23
            ELSE 
                meniscus = 0
                phi_min = 17
            ENDIF
            phi_rad = ASIN((sd1-radial_gap)/r1) + ASIN((sd2-radial_gap)/r2)
            phi_deg = 180*phi_rad/3.1415926
            FORMAT "%#2.1f" LIT
            IF phi_deg < phi_min
                IF meniscus
                    end$ = " < 23 meniscus not autocentered |"
                ELSE 
                    end$ = " < 17  element not autocentered |"
                ENDIF
                out$ = out$ + " " + $STR(phi_deg) +  end$
            ELSE
                c = 0.1/(phi_deg - 7)
                c = INTE(1000*c)/1000
                FORMAT "%#2.2f" LIT
                out$ = out$ + "     " + $STR(phi_deg) + " deg   |          "   
                FORMAT "%#4.1f" LIT
                out$ = out$ + $STR(1000*c) + " um |" 
            ENDIF
        ENDIF
        PRINT out$
        tol_srf = srf
        IF flat1 
            wedge_rad = ABSO(c/r2)
            tol_srf = srf+1
        ELSE
            IF flat2
            wedge_rad = ABSO(c/r1)
            ELSE
                wedge_rad = ABSO(c/(r1-r2))
            ENDIF
        ENDIF
        wedge_deg = 180*wedge_rad/3.1415926
        INSERTTOL 1
        SETTOL 1, 0, "TETY"
        SETTOL 1, 1, tol_srf
        SETTOL 1, 2, tol_srf
        SETTOL 1, 4, -wedge_deg
        SETTOL 1, 5, wedge_deg
    ENDIF
NEXT
PRINT "+---------+---------+-----------------+------------------+"