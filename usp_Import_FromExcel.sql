/* =====================================================================
   Database   : NDRFO22
   Purpose    : Import data dari file Excel (C:\datarfs\datrfs.xlsx)
                ke dalam 5 tabel:
                  - dbo.t_agnt_profile
                  - dbo.t_agnt_address
                  - dbo.t_agnt_dpndt
                  - dbo.t_agnt_rltn
                  - dbo.t_agnt_training
   Requirement:
     1. SQL Server berjalan di mesin yang sama dengan file Excel
        (path C:\datarfs\datrfs.xlsx harus bisa diakses oleh service
        account SQL Server), ATAU gunakan UNC path bila berbeda server.
     2. Provider "Microsoft.ACE.OLEDB.12.0" (Access Database Engine
        Redistributable, 64-bit sesuai versi SQL Server) HARUS
        ter-install di server SQL Server.
     3. Ad Hoc Distributed Queries harus di-enable:
          EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
          EXEC sp_configure 'Ad Hoc Distributed Queries', 1; RECONFIGURE;
     4. Sesuaikan nama SHEET pada tiap OPENROWSET (asumsi default:
        'Sheet1$' untuk data agent, 'Training$' untuk data training).
        Jika Excel Anda punya sheet terpisah untuk address/dependant/
        relation/training, ganti nama sheet pada bagian terkait.
   ===================================================================== */

USE NDRFO22;
GO

IF OBJECT_ID('dbo.usp_Import_AgntProfile_FromExcel', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Import_AgntProfile_FromExcel;
GO

CREATE PROCEDURE dbo.usp_Import_AgntProfile_FromExcel
    @ExcelPath      NVARCHAR(400) = 'C:\datarfs\datrfs.xlsx',
    @SheetAgent     NVARCHAR(100) = 'Sheet1$',
    @SheetTraining  NVARCHAR(100) = 'Training$'
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        ------------------------------------------------------------------
        -- 0. Staging: tarik seluruh sheet agent ke temp table agar
        --    OPENROWSET hanya dieksekusi sekali (performa & konsistensi)
        ------------------------------------------------------------------
        DECLARE @sql NVARCHAR(MAX);

        IF OBJECT_ID('tempdb..#Src') IS NOT NULL DROP TABLE #Src;

        SET @sql = N'
            SELECT *
            INTO #Src
            FROM OPENROWSET(
                ''Microsoft.ACE.OLEDB.12.0'',
                ''Excel 12.0 Xml;HDR=YES;IMEX=1;Database=' + @ExcelPath + ''',
                ''SELECT * FROM [' + @SheetAgent + ']''
            ) AS SrcData;';
        EXEC sp_executesql @sql;

        ------------------------------------------------------------------
        -- 1. dbo.t_agnt_profile
        ------------------------------------------------------------------
        ;WITH SrcProfile AS (
            SELECT
                agnt_cd        = CAST(COALESCE(NULLIF(LTRIM(RTRIM(NEW_AGENT_CODE)), ''), AGNT_CD) AS CHAR(6)),
                agree_typ_cd   = CAST(AGNT_AGREE_TYP_CD AS CHAR(5)),
                agnt_type      = TRY_CAST(AGNT_TYP_CO AS BIT),
                prod_status    = TRY_CAST(PROD_STATUS AS INT),
                title          = CAST(AGNT_TITL_CD AS CHAR(5)),
                first_nm       = CAST(AGNT_GIV_NM AS CHAR(35)),
                last_nm        = CAST(AGNT_LAST_NM AS CHAR(35)),
                clas_cd        = CAST(AGNT_CLAS_CD AS CHAR(5)),
                branch_cd      = CAST(BRANCH AS CHAR(5)),
                mngr_cd        = CAST(AGNT_MGR_CO AS CHAR(6)),
                mngr_lic_cd    = CAST(NULL AS CHAR(10)),
                gender         = TRY_CAST(AGNT_SEX_CD AS BIT),
                religion       = CAST(PELIGION AS CHAR(15)),
                birth_dt       = TRY_CAST(AGNT_BTH_DT AS DATETIME),
                birth_place    = CAST(AGNT_BTH_PLACE_TXT AS CHAR(35)),
                civil_status   = CAST(CVL_STAT_NM AS CHAR(15)),
                nationality    = CAST(NATNL_NM AS CHAR(35)),
                city_id        = CAST(CITY_D AS CHAR(40)),
                tax_id         = CAST(TAX_ID AS CHAR(40)),
                main_empl      = TRY_CAST(MAIN_EMPL AS BIT),
                tax_mrd_status = CAST(TAX_MRD_STATUS AS CHAR(3)),
                tax_num_dpndts = TRY_CAST(TAX_NUM_DPNDTS AS INT),
                bank_cd        = CAST(AGNT_BNK_CD AS CHAR(10)),
                acc_num        = CAST(AGNT_BNK_ACCT_NUM AS CHAR(30)),
                ofc_loctn      = CAST(AGNT_LOC_CD AS CHAR(10)),
                ofc_eff_dt     = TRY_CAST(AGNT_LOC_STAT_DT AS DATETIME),
                dt_cd          = CAST(OT_CD AS CHAR(5)),
                h_phone        = CAST(NULL AS CHAR(50)),
                m_phone        = CAST(MPHONE AS CHAR(50)),
                mpin           = CAST(MPIN AS CHAR(50)),
                edu_type       = CAST(EDUC_LVL_CD AS VARCHAR(10)),
                edu_nm         = CAST(SCHOOL_MM AS VARCHAR(75)),
                att_from       = CAST(ATIND_FROMLYR AS VARCHAR(4)),
                att_to         = CAST(ATND_TO_YR AS VARCHAR(4)),
                cmpny_nm       = CAST(EMPL_CO_NM AS VARCHAR(50)),
                pos            = CAST(EMPL_POSN_NM AS VARCHAR(50)),
                from_dt        = CAST(EMPL_FROM_YR AS VARCHAR(4)),
                to_dt          = CAST(EMPL_TO_YR AS VARCHAR(4)),
                Rcv_dt         = TRY_CAST(RCV_DT AS DATETIME),
                rtnc_dt        = CAST(NULL AS DATETIME),
                crtc_dt        = TRY_CAST(AGNT_ORIG_CNTRCT_DT AS DATETIME),
                exp_flag       = CAST(EXP_FLAG AS CHAR(3)),
                dist_type      = CAST(DIST_TYPE AS CHAR(5)),
                prod_stat_dt   = TRY_CAST(PROD_STAT_DT AS DATETIME),
                extract_dt     = CAST(NULL AS DATETIME),
                prospect_num   = CAST(EMAIL AS VARCHAR(50)),
                bank_bnfcr     = CAST(NULL AS VARCHAR(30)),
                PIN            = CAST(NULL AS CHAR(6)),
                FIR            = CAST(NULL AS INT)
            FROM #Src
        )
        MERGE dbo.t_agnt_profile AS T
        USING (
            SELECT * FROM SrcProfile
            WHERE agnt_cd IS NOT NULL AND LTRIM(RTRIM(agnt_cd)) <> ''
        ) AS S
        ON T.agnt_cd = S.agnt_cd
        WHEN MATCHED THEN
            UPDATE SET
                agree_typ_cd = S.agree_typ_cd, agnt_type = S.agnt_type,
                prod_status = S.prod_status, title = S.title,
                first_nm = S.first_nm, last_nm = S.last_nm,
                clas_cd = S.clas_cd, branch_cd = S.branch_cd,
                mngr_cd = S.mngr_cd, mngr_lic_cd = S.mngr_lic_cd,
                gender = S.gender, religion = S.religion,
                birth_dt = S.birth_dt, birth_place = S.birth_place,
                civil_status = S.civil_status, nationality = S.nationality,
                city_id = S.city_id, tax_id = S.tax_id,
                main_empl = S.main_empl, tax_mrd_status = S.tax_mrd_status,
                tax_num_dpndts = S.tax_num_dpndts, bank_cd = S.bank_cd,
                acc_num = S.acc_num, ofc_loctn = S.ofc_loctn,
                ofc_eff_dt = S.ofc_eff_dt, dt_cd = S.dt_cd,
                m_phone = S.m_phone, mpin = S.mpin,
                edu_type = S.edu_type, edu_nm = S.edu_nm,
                att_from = S.att_from, att_to = S.att_to,
                cmpny_nm = S.cmpny_nm, pos = S.pos,
                from_dt = S.from_dt, to_dt = S.to_dt,
                Rcv_dt = S.Rcv_dt, crtc_dt = S.crtc_dt,
                exp_flag = S.exp_flag, dist_type = S.dist_type,
                prod_stat_dt = S.prod_stat_dt, prospect_num = S.prospect_num
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                agnt_cd, agree_typ_cd, agnt_type, prod_status, title, first_nm, last_nm,
                clas_cd, branch_cd, mngr_cd, mngr_lic_cd, gender, religion, birth_dt,
                birth_place, civil_status, nationality, city_id, tax_id, main_empl,
                tax_mrd_status, tax_num_dpndts, bank_cd, acc_num, ofc_loctn, ofc_eff_dt,
                dt_cd, h_phone, m_phone, mpin, edu_type, edu_nm, att_from, att_to,
                cmpny_nm, pos, from_dt, to_dt, Rcv_dt, rtnc_dt, crtc_dt, exp_flag,
                dist_type, prod_stat_dt, extract_dt, prospect_num, bank_bnfcr, PIN, FIR
            )
            VALUES (
                S.agnt_cd, S.agree_typ_cd, S.agnt_type, S.prod_status, S.title, S.first_nm, S.last_nm,
                S.clas_cd, S.branch_cd, S.mngr_cd, S.mngr_lic_cd, S.gender, S.religion, S.birth_dt,
                S.birth_place, S.civil_status, S.nationality, S.city_id, S.tax_id, S.main_empl,
                S.tax_mrd_status, S.tax_num_dpndts, S.bank_cd, S.acc_num, S.ofc_loctn, S.ofc_eff_dt,
                S.dt_cd, S.h_phone, S.m_phone, S.mpin, S.edu_type, S.edu_nm, S.att_from, S.att_to,
                S.cmpny_nm, S.pos, S.from_dt, S.to_dt, S.Rcv_dt, S.rtnc_dt, S.crtc_dt, S.exp_flag,
                S.dist_type, S.prod_stat_dt, S.extract_dt, S.prospect_num, S.bank_bnfcr, S.PIN, S.FIR
            );

        ------------------------------------------------------------------
        -- 2. dbo.t_agnt_address (dua set alamat -> dua baris per agent)
        ------------------------------------------------------------------
        INSERT INTO dbo.t_agnt_address
            (agnt_cd, add_1, add_2, add_3, city, res_type, zip_cd, mail_flag)
        SELECT
            agnt_cd, add_1, add_2, add_3, city, res_type, zip_cd, mail_flag
        FROM (
            SELECT
                agnt_cd  = CAST(COALESCE(NULLIF(LTRIM(RTRIM(NEW_AGENT_CODE)), ''), AGNT_CD) AS CHAR(6)),
                add_1    = CAST(AGNT_ADOR_ST_TXTI_1 AS CHAR(70)),
                add_2    = CAST(AGNT_ADOR_ST_TXT2_1 AS CHAR(70)),
                add_3    = CAST(AGNT_ADOR_ST_TXT3_1 AS CHAR(70)),
                city     = CAST(AGNT_ADOR_CITY_CO_1 AS CHAR(15)),
                res_type = CAST(ADOR_TYP_CD_1 AS CHAR(5)),
                zip_cd   = CAST(AGNT_MAIL_ADOR_PSTL_TXT_1 AS CHAR(10)),
                mail_flag = TRY_CAST(AGNT_ADOR_MAIL_FLG_1 AS BIT)
            FROM #Src

            UNION ALL

            SELECT
                agnt_cd  = CAST(COALESCE(NULLIF(LTRIM(RTRIM(NEW_AGENT_CODE)), ''), AGNT_CD) AS CHAR(6)),
                add_1    = CAST(AGNT_ADDR_ST_TXT1_2 AS CHAR(70)),
                add_2    = CAST(AGNT_ADDR_ST_TXT2_2 AS CHAR(70)),
                add_3    = CAST(AGNT_ADOR_ST_TXT3_2 AS CHAR(70)),
                city     = CAST(AGNT_ADDR_CITY_CD_2 AS CHAR(15)),
                res_type = CAST(ADDR_TYP_CO_2 AS CHAR(5)),
                zip_cd   = CAST(AGNT_MAIL_ADDR_PSTL_TXT_2 AS CHAR(10)),
                mail_flag = TRY_CAST(AGNT_ADOR_MAIL_FLG_2 AS BIT)
            FROM #Src
        ) AS AddrSet
        WHERE agnt_cd IS NOT NULL AND LTRIM(RTRIM(agnt_cd)) <> ''
          AND (add_1 IS NOT NULL OR add_2 IS NOT NULL OR add_3 IS NOT NULL
               OR city IS NOT NULL OR zip_cd IS NOT NULL);

        ------------------------------------------------------------------
        -- 3. dbo.t_agnt_dpndt (dependant utama + child1 + child2 + child3)
        ------------------------------------------------------------------
        INSERT INTO dbo.t_agnt_dpndt
            (agnt_cd, rel_type, rel_first_nm, rel_last_nm, birth_dt)
        SELECT
            agnt_cd, rel_type, rel_first_nm, rel_last_nm, birth_dt
        FROM (
            SELECT
                agnt_cd      = CAST(COALESCE(NULLIF(LTRIM(RTRIM(NEW_AGENT_CODE)), ''), AGNT_CD) AS CHAR(6)),
                rel_type     = CAST(DPND_REL_CD AS CHAR(5)),
                rel_first_nm = CAST(DPND_GIV_NM AS CHAR(35)),
                rel_last_nm  = CAST(DPND_LAST_NM AS CHAR(35)),
                birth_dt     = TRY_CAST(DPND_BTH_DT AS DATETIME)
            FROM #Src

            UNION ALL

            SELECT
                agnt_cd      = CAST(COALESCE(NULLIF(LTRIM(RTRIM(NEW_AGENT_CODE)), ''), AGNT_CD) AS CHAR(6)),
                rel_type     = CAST(DFIND_PEL_CD_CHILD1 AS CHAR(5)),
                rel_first_nm = CAST(DPNO_GIV_NM_CHILD1 AS CHAR(35)),
                rel_last_nm  = CAST(DPND_LAST_NM_CHILD1 AS CHAR(35)),
                birth_dt     = TRY_CAST(DPND_BTH_DT_CHILD1 AS DATETIME)
            FROM #Src

            UNION ALL

            SELECT
                agnt_cd      = CAST(COALESCE(NULLIF(LTRIM(RTRIM(NEW_AGENT_CODE)), ''), AGNT_CD) AS CHAR(6)),
                rel_type     = CAST(DPND_RELCD_CHILD2 AS CHAR(5)),
                rel_first_nm = CAST(DPND_GIV_NM_CHILD2 AS CHAR(35)),
                rel_last_nm  = CAST(OPNO_LAST_NM_CHILD2 AS CHAR(35)),
                birth_dt     = TRY_CAST(DPND_BTH_DT_CHILD2 AS DATETIME)
            FROM #Src

            UNION ALL

            SELECT
                agnt_cd      = CAST(COALESCE(NULLIF(LTRIM(RTRIM(NEW_AGENT_CODE)), ''), AGNT_CD) AS CHAR(6)),
                rel_type     = CAST(DPND_RELCD_CHILDB AS CHAR(5)),
                rel_first_nm = CAST(DPND_GIV_MM_CHILD3 AS CHAR(35)),
                rel_last_nm  = CAST(DPND_LAST_NM_CHILD3 AS CHAR(35)),
                birth_dt     = TRY_CAST(DPND_BTH_DT_CHILD3 AS DATETIME)
            FROM #Src
        ) AS DpndSet
        WHERE agnt_cd IS NOT NULL AND LTRIM(RTRIM(agnt_cd)) <> ''
          AND (rel_first_nm IS NOT NULL OR rel_last_nm IS NOT NULL OR birth_dt IS NOT NULL);

        ------------------------------------------------------------------
        -- 4. dbo.t_agnt_rltn
        ------------------------------------------------------------------
        INSERT INTO dbo.t_agnt_rltn
            (agnt_cd, rel_agnt_cd, rel_cd)
        SELECT
            agnt_cd     = CAST(COALESCE(NULLIF(LTRIM(RTRIM(NEW_AGENT_CODE)), ''), AGNT_CD) AS CHAR(6)),
            rel_agnt_cd = CAST(REL_AGNT_CD AS CHAR(6)),
            rel_cd      = CAST(REL_CD AS CHAR(5))
        FROM #Src
        WHERE COALESCE(NULLIF(LTRIM(RTRIM(NEW_AGENT_CODE)), ''), AGNT_CD) IS NOT NULL
          AND LTRIM(RTRIM(COALESCE(NULLIF(LTRIM(RTRIM(NEW_AGENT_CODE)), ''), AGNT_CD))) <> ''
          AND REL_AGNT_CD IS NOT NULL
          AND LTRIM(RTRIM(REL_AGNT_CD)) <> '';
        -- Catatan: REL_STRT_DT --> GETDATE() tidak dimasukkan karena
        -- kolom rel_strt_dt tidak ada pada struktur t_agnt_rltn yang
        -- diberikan. Jika kolom tsb memang ada di tabel Anda, tambahkan
        -- rel_strt_dt = GETDATE() pada INSERT di atas.

        ------------------------------------------------------------------
        -- 5. dbo.t_agnt_training (sheet terpisah, mapping 1:1)
        ------------------------------------------------------------------
        IF OBJECT_ID('tempdb..#SrcTraining') IS NOT NULL DROP TABLE #SrcTraining;

        SET @sql = N'
            SELECT *
            INTO #SrcTraining
            FROM OPENROWSET(
                ''Microsoft.ACE.OLEDB.12.0'',
                ''Excel 12.0 Xml;HDR=YES;IMEX=1;Database=' + @ExcelPath + ''',
                ''SELECT * FROM [' + @SheetTraining + ']''
            ) AS SrcData;';
        EXEC sp_executesql @sql;

        INSERT INTO dbo.t_agnt_training
            (agnt_cd, reg_no, training_cd, from_dt, to_dt, lapsed_day, venue, other,
             result, dur, status, remarks, trainer_1, trainer_2, trainer_3, time_stamp)
        SELECT
            agnt_cd     = CAST(AGNT_CD AS CHAR(6)),
            reg_no      = CAST(REG_NO AS CHAR(8)),
            training_cd = CAST(TRAINING_CD AS CHAR(5)),
            from_dt     = TRY_CAST(FROM_DT AS DATETIME),
            to_dt       = TRY_CAST(TO_DT AS DATETIME),
            lapsed_day  = TRY_CAST(LAPSED_DAY AS INT),
            venue       = CAST(VENUE AS CHAR(10)),
            other       = CAST(OTHER AS VARCHAR(75)),
            result      = TRY_CAST(RESULT AS INT),
            dur         = TRY_CAST(DUR AS INT),
            status      = TRY_CAST(STATUS AS INT),
            remarks     = CAST(REMARKS AS CHAR(100)),
            trainer_1   = CAST(TRAINER_1 AS VARCHAR(75)),
            trainer_2   = CAST(TRAINER_2 AS VARCHAR(75)),
            trainer_3   = CAST(TRAINER_3 AS VARCHAR(75)),
            time_stamp  = TRY_CAST(TIME_STAMP AS DATETIME)
        FROM #SrcTraining
        WHERE AGNT_CD IS NOT NULL AND LTRIM(RTRIM(AGNT_CD)) <> '';

        DROP TABLE IF EXISTS #Src;
        DROP TABLE IF EXISTS #SrcTraining;

        COMMIT TRANSACTION;

        SELECT 'Import selesai' AS Result;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;

        DROP TABLE IF EXISTS #Src;
        DROP TABLE IF EXISTS #SrcTraining;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrLine INT = ERROR_LINE();
        RAISERROR('Import gagal pada baris %d. Error: %s', 16, 1, @ErrLine, @ErrMsg);
    END CATCH
END
GO

/* =====================================================================
   Contoh eksekusi:
   EXEC dbo.usp_Import_AgntProfile_FromExcel
        @ExcelPath = 'C:\datarfs\datrfs.xlsx',
        @SheetAgent = 'Sheet1$',
        @SheetTraining = 'Training$';
   ===================================================================== */
