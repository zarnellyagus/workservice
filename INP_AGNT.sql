USE [NDREFO22]
GO
/****** Object:  StoredProcedure [dbo].[sp_import_rfs_agent_all_in_one]    Script Date: 24/08/2026 21:52:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_import_rfs_agent_all_in_one]
    @FilePath NVARCHAR(500) = N'C:\uploadrfs\rfs_agent.xlsx'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -----------------------------------------------------------------------
    -- Validasi parameter file
    -----------------------------------------------------------------------
    SET @FilePath = NULLIF(LTRIM(RTRIM(@FilePath)), N'');

    IF @FilePath IS NULL
    BEGIN
        THROW 50001, 'FilePath tidak boleh kosong.', 1;
    END;

    IF LOWER(RIGHT(@FilePath, 5)) <> N'.xlsx'
    BEGIN
        THROW 50002, 'File harus berekstensi .xlsx.', 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -----------------------------------------------------------------------
        -- 1. Import Sheet1 -> stg_agent_profile
        -----------------------------------------------------------------------
        DECLARE @sqlSheet1 NVARCHAR(MAX);

        SET @sqlSheet1 = N'
        INSERT INTO dbo.stg_agent_profile
        (
            AGNT_CD,
            NEW_AGENT_CODE,
            AGNT_TYP_CD,
            AGNT_MGR_CD,
            AGNT_ORIG_CNTRCT_DT,
            AGNT_CLAS_CD,
            AGNT_AGREE_TYP_CD,
            AGNT_TITL_CD,
            AGNT_LAST_NM,
            AGNT_GIV_NM,
            AGNT_SEX_CD,
            CVL_STAT_NM,
            NATNL_NM,
            AGNT_BTH_DT,
            AGNT_BTH_PLACE_TXT,
            RELIGION,
            CITY_ID,
            TAX_ID,
            AGNT_ADDR_ST_TXT1_1,
            AGNT_ADDR_ST_TXT2_1,
            AGNT_ADDR_ST_TXT3_1,
            AGNT_ADDR_CITY_CD_1,
            AGNT_MAIL_ADDR_PSTL_TXT_1,
            ADDR_TYP_CD_1,
            AGNT_ADDR_MAIL_FLG_1,
            AGNT_ADDR_ST_TXT1_2,
            AGNT_ADDR_ST_TXT2_2,
            AGNT_ADDR_ST_TXT3_2,
            AGNT_ADDR_CITY_CD_2,
            AGNT_MAIL_ADDR_PSTL_TXT_2,
            ADDR_TYP_CD_2,
            AGNT_ADDR_MAIL_FLG_2,
            AGNT_LOC_CD,
            MONT_LOC_STRT_DT,
            DT_CD,
            MSHONE,
            MPIN,
            DPND_LAST_NM,
            DPND_GIV_NM,
            DPND_BTH_DT,
            DPND_REL_CD,
            DPND_LAST_NM_CHILD1,
            DPND_GIV_NM_CHILD1,
            DPND_BTH_DT_CHILD1,
            DPND_REL_CD_CHILD1,
            DPND_LAST_NM_CHILD2,
            DPND_GIV_NM_CHILD2,
            DPND_BTH_DT_CHILD2,
            DPND_REL_CD_CHILD2,
            DPND_LAST_NM_CHILD3,
            DPND_GIV_NM_CHILD3,
            DPND_BTH_DT_CHILD3,
            DPND_REL_CD_CHILD3,
            EDUC_LVL_CD,
            SCHOOL_NM,
            ATND_FROM_YR,
            ATND_TO_YR,
            EMPL_CO_NM,
            EMPL_POSN_NM,
            EMPL_FROM_YR,
            EMPL_TO_YR,
            REL_AGNT_CD,
            REL_CD,
            REL_STRT_DT,
            EMAIL,
            MAIN_EMPL,
            TAX_MRD_STATUS,
            TAX_NUM_DPNDTS,
            AGNT_BNK_CD,
            AGNT_BNK_ACCT_NUM,
            PROD_STATUS,
            PROD_STAT_DT,
            RCV_DT,
            BRANCH,
            EXP_FLAG,
            DIST_TYPE,
			upload_date
        )
        SELECT
            [AGNT_CD],
            [NEW_AGENT_CODE],
            [AGNT_TYP_CD],
            [AGNT_MGR_CD],
            [AGNT_ORIG_CNTRCT_DT],
            [AGNT_CLAS_CD],
            [AGNT_AGREE_TYP_CD],
            [AGNT_TITL_CD],
            [AGNT_LAST_NM],
            [AGNT_GIV_NM],
            [AGNT_SEX_CD],
            [CVL_STAT_NM],
            [NATNL_NM],
            [AGNT_BTH_DT],
            [AGNT_BTH_PLACE_TXT],
            [RELIGION],
            [CITY_ID],
            [TAX_ID],
            [AGNT_ADDR_ST_TXT1_1],
            [AGNT_ADDR_ST_TXT2_1],
            [AGNT_ADDR_ST_TXT3_1],
            [AGNT_ADDR_CITY_CD_1],
            [AGNT_MAIL_ADDR_PSTL_TXT_1],
            [ADDR_TYP_CD_1],
            [AGNT_ADDR_MAIL_FLG_1],
            [AGNT_ADDR_ST_TXT1_2],
            [AGNT_ADDR_ST_TXT2_2],
            [AGNT_ADDR_ST_TXT3_2],
            [AGNT_ADDR_CITY_CD_2],
            [AGNT_MAIL_ADDR_PSTL_TXT_2],
            [ADDR_TYP_CD_2],
            [AGNT_ADDR_MAIL_FLG_2],
            [AGNT_LOC_CD],
            [MONT_LOC_STRT_DT],
            [DT_CD],
            [MSHONE],
            [MPIN],
            [DPND_LAST_NM],
            [DPND_GIV_NM],
            [DPND_BTH_DT],
            [DPND_REL_CD],
            [DPND_LAST_NM_CHILD1],
            [DPND_GIV_NM_CHILD1],
            [DPND_BTH_DT_CHILD1],
            [DPND_REL_CD_CHILD1],
            [DPND_LAST_NM_CHILD2],
            [DPND_GIV_NM_CHILD2],
            [DPND_BTH_DT_CHILD2],
            [DPND_REL_CD_CHILD2],
            [DPND_LAST_NM_CHILD3],
            [DPND_GIV_NM_CHILD3],
            [DPND_BTH_DT_CHILD3],
            [DPND_REL_CD_CHILD3],
            [EDUC_LVL_CD],
            [SCHOOL_NM],
            [ATND_FROM_YR],
            [ATND_TO_YR],
            [EMPL_CO_NM],
            [EMPL_POSN_NM],
            [EMPL_FROM_YR],
            [EMPL_TO_YR],
            [REL_AGNT_CD],
            [REL_CD],
            [REL_STRT_DT],
            [EMAIL],
            [MAIN_EMPL],
            [TAX_MRD_STATUS],
            [TAX_NUM_DPNDTS],
            [AGNT_BNK_CD],
            [AGNT_BNK_ACCT_NUM],
            [PROD_STATUS],
            [PROD_STAT_DT],
            [RCV_DT],
            [BRANCH],
            [EXP_FLAG],
            [DIST_TYPE],
			GETDATE()
        FROM OPENROWSET
        (
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0 Xml;Database='
            + REPLACE(@FilePath, '''', '''''')
            + ';HDR=YES;IMEX=1'',
            ''SELECT
                [AGNT_CD],
                [NEW_AGENT_CODE],
                [AGNT_TYP_CD],
                [AGNT_MGR_CD],
                [AGNT_ORIG_CNTRCT_DT],
                [AGNT_CLAS_CD],
                [AGNT_AGREE_TYP_CD],
                [AGNT_TITL_CD],
                [AGNT_LAST_NM],
                [AGNT_GIV_NM],
                [AGNT_SEX_CD],
                [CVL_STAT_NM],
                [NATNL_NM],
                [AGNT_BTH_DT],
                [AGNT_BTH_PLACE_TXT],
                [RELIGION],
                [CITY_ID],
                [TAX_ID],
                [AGNT_ADDR_ST_TXT1_1],
                [AGNT_ADDR_ST_TXT2_1],
                [AGNT_ADDR_ST_TXT3_1],
                [AGNT_ADDR_CITY_CD_1],
                [AGNT_MAIL_ADDR_PSTL_TXT_1],
                [ADDR_TYP_CD_1],
                [AGNT_ADDR_MAIL_FLG_1],
                [AGNT_ADDR_ST_TXT1_2],
                [AGNT_ADDR_ST_TXT2_2],
                [AGNT_ADDR_ST_TXT3_2],
                [AGNT_ADDR_CITY_CD_2],
                [AGNT_MAIL_ADDR_PSTL_TXT_2],
                [ADDR_TYP_CD_2],
                [AGNT_ADDR_MAIL_FLG_2],
                [AGNT_LOC_CD],
                [MONT_LOC_STRT_DT],
                [DT_CD],
                [MSHONE],
                [MPIN],
                [DPND_LAST_NM],
                [DPND_GIV_NM],
                [DPND_BTH_DT],
                [DPND_REL_CD],
                [DPND_LAST_NM_CHILD1],
                [DPND_GIV_NM_CHILD1],
                [DPND_BTH_DT_CHILD1],
                [DPND_REL_CD_CHILD1],
                [DPND_LAST_NM_CHILD2],
                [DPND_GIV_NM_CHILD2],
                [DPND_BTH_DT_CHILD2],
                [DPND_REL_CD_CHILD2],
                [DPND_LAST_NM_CHILD3],
                [DPND_GIV_NM_CHILD3],
                [DPND_BTH_DT_CHILD3],
                [DPND_REL_CD_CHILD3],
                [EDUC_LVL_CD],
                [SCHOOL_NM],
                [ATND_FROM_YR],
                [ATND_TO_YR],
                [EMPL_CO_NM],
                [EMPL_POSN_NM],
                [EMPL_FROM_YR],
                [EMPL_TO_YR],
                [REL_AGNT_CD],
                [REL_CD],
                [REL_STRT_DT],
                [EMAIL],
                [MAIN_EMPL],
                [TAX_MRD_STATUS],
                [TAX_NUM_DPNDTS],
                [AGNT_BNK_CD],
                [AGNT_BNK_ACCT_NUM],
                [PROD_STATUS],
                [PROD_STAT_DT],
                [RCV_DT],
                [BRANCH],
                [EXP_FLAG],
                [DIST_TYPE]
             FROM [Sheet1$]''
        );';

        EXEC sys.sp_executesql @sqlSheet1;

        -----------------------------------------------------------------------
        -- 2. Import Sheet2 -> stg_agnt_training
        -----------------------------------------------------------------------
        DECLARE @sqlSheet2 NVARCHAR(MAX);

        SET @sqlSheet2 = N'
        INSERT INTO dbo.stg_agnt_training
        (
            AGNT_CD,
            REG_NO,
            TRAINING_CD,
            FROM_DT,
            TO_DT,
            LAPSED_DAY,
            VENUE,
            OTHER,
            RESULT,
            DUR,
            STATUS,
            REMARKS,
            TRAINER_1,
            TRAINER_2,
            TRAINER_3
        )
        SELECT
            [AGNT_CD],
            [REG_NO],
            [TRAINING_CD],
            [FROM_DT],
            [TO_DT],
            [LAPSED_DAY],
            [VENUE],
            [OTHER],
            [RESULT],
            [DUR],
            [STATUS],
            [REMARKS],
            [TRAINER_1],
            [TRAINER_2],
            [TRAINER_3]
        FROM OPENROWSET
        (
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0 Xml;Database='
            + REPLACE(@FilePath, '''', '''''')
            + ';HDR=YES;IMEX=1'',
            ''SELECT
                [AGNT_CD],
                [REG_NO],
                [TRAINING_CD],
                [FROM_DT],
                [TO_DT],
                [LAPSED_DAY],
                [VENUE],
                [OTHER],
                [RESULT],
                [DUR],
                [STATUS],
                [REMARKS],
                [TRAINER_1],
                [TRAINER_2],
                [TRAINER_3]
             FROM [Sheet2$A:P]''
        );';

        EXEC sys.sp_executesql @sqlSheet2;

        -----------------------------------------------------------------------
        -- 3. Insert stg_agent_profile -> t_agnt_profile
        -----------------------------------------------------------------------
        INSERT INTO dbo.t_agnt_profile
        (
            agnt_cd,
            agnt_type,
            mgr_cd,
            crtc_dt,
            clas_cd,
            agree_typ_cd,
            title,
            last_nm,
            first_nm,
            gender,
            civil_status,
            nationality,
            birth_dt,
            birth_place,
            religion,
            city_id,
            tax_id,
            ofc_loctn,
            ofc_eff_dt,
            dt_cd,
            m_phone,
            mpin,
            edu_type,
            edu_nm,
            att_from,
            att_to,
            cmpny_nm,
            pos,
            from_dt,
            to_dt,
            prospect_num,
            main_empl,
            tax_mrd_status,
            tax_num_dpndts,
            bank_cd,
            acc_num,
            prod_status,
            prod_stat_dt,
            rcv_dt,
            branch_cd,
            exp_flag,
            dist_type
        )
        SELECT
            ISNULL(NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''), s.AGNT_CD),
            s.AGNT_TYP_CD,
            s.AGNT_MGR_CD,
            TRY_CONVERT(DATE, s.AGNT_ORIG_CNTRCT_DT),
            s.AGNT_CLAS_CD,
            s.AGNT_AGREE_TYP_CD,
            s.AGNT_TITL_CD,
            s.AGNT_LAST_NM,
            s.AGNT_GIV_NM,
            s.AGNT_SEX_CD,
            s.CVL_STAT_NM,
            s.NATNL_NM,
            TRY_CONVERT(DATE, s.AGNT_BTH_DT),
            s.AGNT_BTH_PLACE_TXT,
            s.RELIGION,
            s.CITY_ID,
            s.TAX_ID,
            s.AGNT_LOC_CD,
            TRY_CONVERT(DATE, s.MONT_LOC_STRT_DT),
            s.DT_CD,
            s.MSHONE,
            s.MPIN,
            s.EDUC_LVL_CD,
            s.SCHOOL_NM,
            s.ATND_FROM_YR,
            s.ATND_TO_YR,
            s.EMPL_CO_NM,
            s.EMPL_POSN_NM,
            s.EMPL_FROM_YR,
            s.EMPL_TO_YR,
            s.EMAIL,
            s.MAIN_EMPL,
            s.TAX_MRD_STATUS,
            s.TAX_NUM_DPNDTS,
            s.AGNT_BNK_CD,
            s.AGNT_BNK_ACCT_NUM,
            s.PROD_STATUS,
            TRY_CONVERT(DATE, s.PROD_STAT_DT),
            TRY_CONVERT(DATE, s.RCV_DT),
            s.BRANCH,
            s.EXP_FLAG,
            s.DIST_TYPE
        FROM dbo.stg_agent_profile AS s
        WHERE NULLIF(
                  LTRIM(RTRIM(
                      ISNULL(NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''), s.AGNT_CD)
                  )),
                  ''
              ) IS NOT NULL
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.t_agnt_profile AS p
              WHERE p.agnt_cd =
                    ISNULL(NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''), s.AGNT_CD)
          );

        -----------------------------------------------------------------------
        -- 4. Insert address
        -----------------------------------------------------------------------
        INSERT INTO dbo.t_agnt_address
        (
            agnt_cd,
            add_1,
            add_2,
            add_3,
            city,
            zip_cd,
            res_type,
            mail_flag
        )
        SELECT
            ISNULL(NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''), s.AGNT_CD),
            s.AGNT_ADDR_ST_TXT1_1,
            s.AGNT_ADDR_ST_TXT2_1,
            s.AGNT_ADDR_ST_TXT3_1,
            s.AGNT_ADDR_CITY_CD_1,
            s.AGNT_MAIL_ADDR_PSTL_TXT_1,
            s.ADDR_TYP_CD_1,
            s.AGNT_ADDR_MAIL_FLG_1
        FROM dbo.stg_agent_profile AS s
        WHERE NULLIF(
                  LTRIM(RTRIM(
                      ISNULL(NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''), s.AGNT_CD)
                  )),
                  ''
              ) IS NOT NULL
          AND (
                s.AGNT_ADDR_ST_TXT1_1 IS NOT NULL OR
                s.AGNT_ADDR_ST_TXT2_1 IS NOT NULL OR
                s.AGNT_ADDR_ST_TXT3_1 IS NOT NULL OR
                s.AGNT_ADDR_CITY_CD_1 IS NOT NULL
              )

        UNION ALL

        SELECT
            ISNULL(NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''), s.AGNT_CD),
            s.AGNT_ADDR_ST_TXT1_2,
            s.AGNT_ADDR_ST_TXT2_2,
            s.AGNT_ADDR_ST_TXT3_2,
            s.AGNT_ADDR_CITY_CD_2,
            s.AGNT_MAIL_ADDR_PSTL_TXT_2,
            s.ADDR_TYP_CD_2,
            s.AGNT_ADDR_MAIL_FLG_2
        FROM dbo.stg_agent_profile AS s
        WHERE NULLIF(
                  LTRIM(RTRIM(
                      ISNULL(NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''), s.AGNT_CD)
                  )),
                  ''
              ) IS NOT NULL
          AND (
                s.AGNT_ADDR_ST_TXT1_2 IS NOT NULL OR
                s.AGNT_ADDR_ST_TXT2_2 IS NOT NULL OR
                s.AGNT_ADDR_ST_TXT3_2 IS NOT NULL OR
                s.AGNT_ADDR_CITY_CD_2 IS NOT NULL
              );

        -----------------------------------------------------------------------
        -- 5. Insert dependent
        -----------------------------------------------------------------------
        INSERT INTO dbo.t_agnt_dpndt
        (
            agnt_cd,
            rel_last_nm,
            rel_first_nm,
            birth_dt,
            rel_type
        )
        SELECT
            x.agnt_cd,
            x.rel_last_nm,
            x.rel_first_nm,
            x.birth_dt,
            x.rel_type
        FROM
        (
            SELECT
                ISNULL(NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''), s.AGNT_CD) AS agnt_cd,
                s.DPND_LAST_NM AS rel_last_nm,
                s.DPND_GIV_NM AS rel_first_nm,
                TRY_CONVERT(DATE, s.DPND_BTH_DT) AS birth_dt,
                s.DPND_REL_CD AS rel_type
            FROM dbo.stg_agent_profile AS s

            UNION ALL

            SELECT
                ISNULL(NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''), s.AGNT_CD),
                s.DPND_LAST_NM_CHILD1,
                s.DPND_GIV_NM_CHILD1,
                TRY_CONVERT(DATE, s.DPND_BTH_DT_CHILD1),
                s.DPND_REL_CD_CHILD1
            FROM dbo.stg_agent_profile AS s

            UNION ALL

            SELECT
                ISNULL(NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''), s.AGNT_CD),
                s.DPND_LAST_NM_CHILD2,
                s.DPND_GIV_NM_CHILD2,
                TRY_CONVERT(DATE, s.DPND_BTH_DT_CHILD2),
                s.DPND_REL_CD_CHILD2
            FROM dbo.stg_agent_profile AS s

            UNION ALL

            SELECT
                ISNULL(NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''), s.AGNT_CD),
                s.DPND_LAST_NM_CHILD3,
                s.DPND_GIV_NM_CHILD3,
                TRY_CONVERT(DATE, s.DPND_BTH_DT_CHILD3),
                s.DPND_REL_CD_CHILD3
            FROM dbo.stg_agent_profile AS s
        ) AS x
        WHERE x.agnt_cd IS NOT NULL
          AND (
                x.rel_last_nm IS NOT NULL OR
                x.rel_first_nm IS NOT NULL OR
                x.birth_dt IS NOT NULL OR
                x.rel_type IS NOT NULL
              );

        -----------------------------------------------------------------------
        -- 6. Insert relation
        -----------------------------------------------------------------------
        INSERT INTO dbo.t_agnt_rltn
        (
            agnt_cd,
            rel_agnt_cd,
            rel_cd
        )
        SELECT
            ISNULL(NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''), s.AGNT_CD),
            s.REL_AGNT_CD,
            s.REL_CD
        FROM dbo.stg_agent_profile AS s
        WHERE ISNULL(NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''), s.AGNT_CD) IS NOT NULL
          AND (
                s.REL_AGNT_CD IS NOT NULL OR
                s.REL_CD IS NOT NULL
              );

        -----------------------------------------------------------------------
        -- 7. Insert training
        -----------------------------------------------------------------------
        INSERT INTO dbo.t_agnt_training
        (
            agnt_cd,
            reg_no,
            training_cd,
            from_dt,
            to_dt,
            lapsed_day,
            venue,
            other,
            result,
            dur,
            status,
            remarks,
            trainer_1,
            trainer_2,
            trainer_3
        )
        SELECT
            ISNULL(
                NULLIF(LTRIM(RTRIM(p.NEW_AGENT_CODE)), ''),
                t.AGNT_CD
            ),
            NULL,
            t.TRAINING_CD,
            TRY_CONVERT(DATE, t.FROM_DT),
            TRY_CONVERT(DATE, t.TO_DT),
            0,
            t.VENUE,
            NULL,
            80,
            0,
            1,
            NULL,
            NULL,
            NULL,
            NULL
        FROM dbo.stg_agnt_training AS t
        LEFT JOIN dbo.stg_agent_profile AS p
            ON p.AGNT_CD = t.AGNT_CD
        WHERE NULLIF(LTRIM(RTRIM(t.AGNT_CD)), '') IS NOT NULL
          AND NULLIF(LTRIM(RTRIM(t.TRAINING_CD)), '') IS NOT NULL;

        -----------------------------------------------------------------------
        -- 8. Insert log ke t_log
        -----------------------------------------------------------------------
        INSERT INTO dbo.t_log
        (
            agnt_cd
        )
        SELECT DISTINCT
            ISNULL(
                NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''),
                s.AGNT_CD
            )
        FROM dbo.stg_agent_profile AS s
        WHERE NULLIF(
                  LTRIM(RTRIM(
                      ISNULL(
                          NULLIF(LTRIM(RTRIM(s.NEW_AGENT_CODE)), ''),
                          s.AGNT_CD
                      )
                  )),
                  ''
              ) IS NOT NULL;

        -----------------------------------------------------------------------
        -- Commit transaction
        -----------------------------------------------------------------------
        COMMIT TRANSACTION;

        -----------------------------------------------------------------------
        -- Ringkasan hasil
        -----------------------------------------------------------------------
        SELECT
            'Import berhasil' AS status_import,
            @FilePath AS file_path,
            (SELECT COUNT(*) FROM dbo.stg_agent_profile) AS jumlah_profile_staging,
            (SELECT COUNT(*) FROM dbo.stg_agnt_training) AS jumlah_training_staging,
            (SELECT COUNT(*) FROM dbo.t_log) AS jumlah_log;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
END;
