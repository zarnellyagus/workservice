CREATE OR ALTER PROCEDURE dbo.SP_IMPORT_RFS_AGENT
(
    @AgentFilePath     NVARCHAR(4000) = N'C:\uploadrfs\rfs_agent.csv',
    @TrainingFilePath  NVARCHAR(4000) = N'C:\uploadrfs\rfs_agent_trening.csv',
    @UploadDate        DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @UploadDate IS NULL
        SET @UploadDate = GETDATE();

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NULLIF(LTRIM(RTRIM(@AgentFilePath)), N'') IS NULL
            THROW 50001, 'Path file agent tidak boleh kosong.', 1;

        IF NULLIF(LTRIM(RTRIM(@TrainingFilePath)), N'') IS NULL
            THROW 50002, 'Path file training tidak boleh kosong.', 1;

        IF OBJECT_ID('tempdb..#AgentFile') IS NOT NULL
            DROP TABLE #AgentFile;

        CREATE TABLE #AgentFile
        (
            AGNT_CD NVARCHAR(255) NULL,
            NEW_AGENT_CODE NVARCHAR(255) NULL,
            AGNT_TYP_CD NVARCHAR(255) NULL,
            AGNT_MGR_CD NVARCHAR(255) NULL,
            AGNT_ORIG_CNTRCT_DT NVARCHAR(255) NULL,
            AGNT_CLAS_CD NVARCHAR(255) NULL,
            AGNT_AGREE_TYP_CD NVARCHAR(255) NULL,
            AGNT_TITL_CD NVARCHAR(255) NULL,
            AGNT_LAST_NM NVARCHAR(255) NULL,
            AGNT_GIV_NM NVARCHAR(255) NULL,
            AGNT_SEX_CD NVARCHAR(255) NULL,
            CVL_STAT_NM NVARCHAR(255) NULL,
            NATNL_NM NVARCHAR(255) NULL,
            AGNT_BTH_DT NVARCHAR(255) NULL,
            AGNT_BTH_PLACE_TXT NVARCHAR(255) NULL,
            RELIGION NVARCHAR(255) NULL,
            CITY_ID NVARCHAR(255) NULL,
            TAX_ID NVARCHAR(255) NULL,
            AGNT_ADDR_ST_TXT1_1 NVARCHAR(255) NULL,
            AGNT_ADDR_ST_TXT2_1 NVARCHAR(255) NULL,
            AGNT_ADDR_ST_TXT3_1 NVARCHAR(255) NULL,
            AGNT_ADDR_CITY_CD_1 NVARCHAR(255) NULL,
            AGNT_MAIL_ADDR_PSTL_TXT_1 NVARCHAR(255) NULL,
            ADDR_TYP_CD_1 NVARCHAR(255) NULL,
            AGNT_ADDR_MAIL_FLG_1 NVARCHAR(255) NULL,
            AGNT_ADDR_ST_TXT1_2 NVARCHAR(255) NULL,
            AGNT_ADDR_ST_TXT2_2 NVARCHAR(255) NULL,
            AGNT_ADDR_ST_TXT3_2 NVARCHAR(255) NULL,
            AGNT_ADDR_CITY_CD_2 NVARCHAR(255) NULL,
            AGNT_MAIL_ADDR_PSTL_TXT_2 NVARCHAR(255) NULL,
            ADDR_TYP_CD_2 NVARCHAR(255) NULL,
            AGNT_ADDR_MAIL_FLG_2 NVARCHAR(255) NULL,
            AGNT_LOC_CD NVARCHAR(255) NULL,
            MONT_LOC_STRT_DT NVARCHAR(255) NULL,
            DT_CD NVARCHAR(255) NULL,
            MPHOME NVARCHAR(255) NULL,
            MPIN NVARCHAR(255) NULL,
            DPND_LAST_NM NVARCHAR(255) NULL,
            DPND_GIV_NM NVARCHAR(255) NULL,
            DPND_BTH_DT NVARCHAR(255) NULL,
            DPND_REL_CD NVARCHAR(255) NULL,
            DPND_LAST_NM_CHILD1 NVARCHAR(255) NULL,
            DPND_GIV_NM_CHILD1 NVARCHAR(255) NULL,
            DPND_BTH_DT_CHILD1 NVARCHAR(255) NULL,
            DPND_REL_CD_CHILD1 NVARCHAR(255) NULL,
            DPND_LAST_NM_CHILD2 NVARCHAR(255) NULL,
            DPND_GIV_NM_CHILD2 NVARCHAR(255) NULL,
            DPND_BTH_DT_CHILD2 NVARCHAR(255) NULL,
            DPND_REL_CD_CHILD2 NVARCHAR(255) NULL,
            DPND_LAST_NM_CHILD3 NVARCHAR(255) NULL,
            DPND_GIV_NM_CHILD3 NVARCHAR(255) NULL,
            DPND_BTH_DT_CHILD3 NVARCHAR(255) NULL,
            DPND_REL_CD_CHILD3 NVARCHAR(255) NULL,
            EDUC_LVL_CD NVARCHAR(255) NULL,
            SCHOOL_NM NVARCHAR(255) NULL,
            ATND_FROM_YR NVARCHAR(255) NULL,
            ATND_TO_YR NVARCHAR(255) NULL,
            EMPL_CO_NM NVARCHAR(255) NULL,
            EMPL_POSN_NM NVARCHAR(255) NULL,
            EMPL_FROM_YR NVARCHAR(255) NULL,
            EMPL_TO_YR NVARCHAR(255) NULL,
            REL_AGNT_CD NVARCHAR(255) NULL,
            REL_CD NVARCHAR(255) NULL,
            REL_STRT_DT NVARCHAR(255) NULL,
            EMAIL NVARCHAR(255) NULL,
            MAIN_EMPL NVARCHAR(255) NULL,
            TAX_MRD_STATUS NVARCHAR(255) NULL,
            TAX_NUM_DPNDTS NVARCHAR(255) NULL,
            AGNT_BNK_CD NVARCHAR(255) NULL,
            AGNT_BNK_ACCT_NUM NVARCHAR(255) NULL,
            PROD_STATUS NVARCHAR(255) NULL,
            PROD_STAT_DT NVARCHAR(255) NULL,
            RCV_DT NVARCHAR(255) NULL,
            BRANCH NVARCHAR(255) NULL,
            EXP_FLAG NVARCHAR(255) NULL,
            DIST_TYPE NVARCHAR(255) NULL
        );

        DECLARE @SqlAgent NVARCHAR(MAX);

        SET @SqlAgent = N'
            BULK INSERT #AgentFile
            FROM ''' + REPLACE(@AgentFilePath, '''', '''''') + N'''
            WITH
            (
                FIRSTROW = 2,
                DATAFILETYPE = ''char'',
                FIELDTERMINATOR = '';'',
                ROWTERMINATOR = ''0x0a'',
                CODEPAGE = ''65001'',
                KEEPNULLS,
                TABLOCK
            );';

        EXEC sys.sp_executesql @SqlAgent;

        UPDATE #AgentFile
        SET
            AGNT_CD               = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(AGNT_CD, CHAR(13), N''), CHAR(10), N''))), N''),
            NEW_AGENT_CODE        = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(NEW_AGENT_CODE, CHAR(13), N''), CHAR(10), N''))), N''),
            AGNT_ORIG_CNTRCT_DT   = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(AGNT_ORIG_CNTRCT_DT, CHAR(13), N''), CHAR(10), N''))), N''),
            AGNT_BTH_DT           = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(AGNT_BTH_DT, CHAR(13), N''), CHAR(10), N''))), N''),
            MONT_LOC_STRT_DT      = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(MONT_LOC_STRT_DT, CHAR(13), N''), CHAR(10), N''))), N''),
            DPND_BTH_DT           = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(DPND_BTH_DT, CHAR(13), N''), CHAR(10), N''))), N''),
            DPND_BTH_DT_CHILD1    = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(DPND_BTH_DT_CHILD1, CHAR(13), N''), CHAR(10), N''))), N''),
            DPND_BTH_DT_CHILD2    = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(DPND_BTH_DT_CHILD2, CHAR(13), N''), CHAR(10), N''))), N''),
            DPND_BTH_DT_CHILD3    = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(DPND_BTH_DT_CHILD3, CHAR(13), N''), CHAR(10), N''))), N''),
            REL_STRT_DT           = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REL_STRT_DT, CHAR(13), N''), CHAR(10), N''))), N''),
            PROD_STAT_DT          = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(PROD_STAT_DT, CHAR(13), N''), CHAR(10), N''))), N''),
            RCV_DT                = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(RCV_DT, CHAR(13), N''), CHAR(10), N''))), N''),
            DIST_TYPE             = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(DIST_TYPE, CHAR(13), N''), CHAR(10), N''))), N'');

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
            MPHOME,
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
            NULLIF(LTRIM(RTRIM(S.AGNT_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.NEW_AGENT_CODE)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_TYP_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_MGR_CD)), N''),
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.AGNT_ORIG_CNTRCT_DT)), N''), 103),
            NULLIF(LTRIM(RTRIM(S.AGNT_CLAS_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_AGREE_TYP_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_TITL_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_LAST_NM)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_GIV_NM)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_SEX_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.CVL_STAT_NM)), N''),
            NULLIF(LTRIM(RTRIM(S.NATNL_NM)), N''),
            CASE
                WHEN TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.AGNT_BTH_DT)), N''), 103) = CONVERT(DATE, '19000101')
                    THEN NULL
                ELSE TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.AGNT_BTH_DT)), N''), 103)
            END,
            NULLIF(LTRIM(RTRIM(S.AGNT_BTH_PLACE_TXT)), N''),
            NULLIF(LTRIM(RTRIM(S.RELIGION)), N''),
            NULLIF(LTRIM(RTRIM(S.CITY_ID)), N''),
            NULLIF(LTRIM(RTRIM(S.TAX_ID)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT1_1)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT2_1)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT3_1)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_CITY_CD_1)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_MAIL_ADDR_PSTL_TXT_1)), N''),
            NULLIF(LTRIM(RTRIM(S.ADDR_TYP_CD_1)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_MAIL_FLG_1)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT1_2)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT2_2)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT3_2)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_CITY_CD_2)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_MAIL_ADDR_PSTL_TXT_2)), N''),
            NULLIF(LTRIM(RTRIM(S.ADDR_TYP_CD_2)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_MAIL_FLG_2)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_LOC_CD)), N''),
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.MONT_LOC_STRT_DT)), N''), 103),
            NULLIF(LTRIM(RTRIM(S.DT_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.MPHOME)), N''),
            NULLIF(LTRIM(RTRIM(S.MPIN)), N''),
            NULLIF(LTRIM(RTRIM(S.DPND_LAST_NM)), N''),
            NULLIF(LTRIM(RTRIM(S.DPND_GIV_NM)), N''),
            CASE
                WHEN TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.DPND_BTH_DT)), N''), 103) = CONVERT(DATE, '19000101')
                    THEN NULL
                ELSE TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.DPND_BTH_DT)), N''), 103)
            END,
            NULLIF(LTRIM(RTRIM(S.DPND_REL_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.DPND_LAST_NM_CHILD1)), N''),
            NULLIF(LTRIM(RTRIM(S.DPND_GIV_NM_CHILD1)), N''),
            CASE
                WHEN TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.DPND_BTH_DT_CHILD1)), N''), 103) = CONVERT(DATE, '19000101')
                    THEN NULL
                ELSE TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.DPND_BTH_DT_CHILD1)), N''), 103)
            END,
            NULLIF(LTRIM(RTRIM(S.DPND_REL_CD_CHILD1)), N''),
            NULLIF(LTRIM(RTRIM(S.DPND_LAST_NM_CHILD2)), N''),
            NULLIF(LTRIM(RTRIM(S.DPND_GIV_NM_CHILD2)), N''),
            CASE
                WHEN TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.DPND_BTH_DT_CHILD2)), N''), 103) = CONVERT(DATE, '19000101')
                    THEN NULL
                ELSE TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.DPND_BTH_DT_CHILD2)), N''), 103)
            END,
            NULLIF(LTRIM(RTRIM(S.DPND_REL_CD_CHILD2)), N''),
            NULLIF(LTRIM(RTRIM(S.DPND_LAST_NM_CHILD3)), N''),
            NULLIF(LTRIM(RTRIM(S.DPND_GIV_NM_CHILD3)), N''),
            CASE
                WHEN TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.DPND_BTH_DT_CHILD3)), N''), 103) = CONVERT(DATE, '19000101')
                    THEN NULL
                ELSE TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.DPND_BTH_DT_CHILD3)), N''), 103)
            END,
            NULLIF(LTRIM(RTRIM(S.DPND_REL_CD_CHILD3)), N''),
            NULLIF(LTRIM(RTRIM(S.EDUC_LVL_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.SCHOOL_NM)), N''),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(S.ATND_FROM_YR)), N'')),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(S.ATND_TO_YR)), N'')),
            NULLIF(LTRIM(RTRIM(S.EMPL_CO_NM)), N''),
            NULLIF(LTRIM(RTRIM(S.EMPL_POSN_NM)), N''),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(S.EMPL_FROM_YR)), N'')),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(S.EMPL_TO_YR)), N'')),
            NULLIF(LTRIM(RTRIM(S.REL_AGNT_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.REL_CD)), N''),
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.REL_STRT_DT)), N''), 103),
            NULLIF(LTRIM(RTRIM(S.EMAIL)), N''),
            NULLIF(LTRIM(RTRIM(S.MAIN_EMPL)), N''),
            NULLIF(LTRIM(RTRIM(S.TAX_MRD_STATUS)), N''),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(S.TAX_NUM_DPNDTS)), N'')),
            NULLIF(LTRIM(RTRIM(S.AGNT_BNK_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_BNK_ACCT_NUM)), N''),
            NULLIF(LTRIM(RTRIM(S.PROD_STATUS)), N''),
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.PROD_STAT_DT)), N''), 103),
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.RCV_DT)), N''), 103),
            NULLIF(LTRIM(RTRIM(S.BRANCH)), N''),
            NULLIF(LTRIM(RTRIM(S.EXP_FLAG)), N''),
            NULLIF(LTRIM(RTRIM(S.DIST_TYPE)), N''),
            @UploadDate
        FROM #AgentFile S;

        IF OBJECT_ID('tempdb..#TrainingFile') IS NOT NULL
            DROP TABLE #TrainingFile;

        CREATE TABLE #TrainingFile
        (
            AGNT_CD NVARCHAR(255) NULL,
            REG_NO NVARCHAR(255) NULL,
            TRAINING_CD NVARCHAR(255) NULL,
            FROM_DT NVARCHAR(255) NULL,
            TO_DT NVARCHAR(255) NULL,
            LAPSED_DAY NVARCHAR(255) NULL,
            VENUE NVARCHAR(255) NULL,
            OTHER NVARCHAR(255) NULL,
            RESULT NVARCHAR(255) NULL,
            DUR NVARCHAR(255) NULL,
            STATUS NVARCHAR(255) NULL,
            REMARKS NVARCHAR(255) NULL,
            TRAINER_1 NVARCHAR(255) NULL,
            TRAINER_2 NVARCHAR(255) NULL,
            TRAINER_3 NVARCHAR(255) NULL,
            TIME_STAMP NVARCHAR(255) NULL
        );

        DECLARE @SqlTraining NVARCHAR(MAX);

        SET @SqlTraining = N'
            BULK INSERT #TrainingFile
            FROM ''' + REPLACE(@TrainingFilePath, '''', '''''') + N'''
            WITH
            (
                FIRSTROW = 2,
                DATAFILETYPE = ''char'',
                FIELDTERMINATOR = '';'',
                ROWTERMINATOR = ''0x0a'',
                CODEPAGE = ''65001'',
                KEEPNULLS,
                TABLOCK
            );';

        EXEC sys.sp_executesql @SqlTraining;

        UPDATE #TrainingFile
        SET
            AGNT_CD     = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(AGNT_CD, CHAR(13), N''), CHAR(10), N''))), N''),
            REG_NO      = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(REG_NO, CHAR(13), N''), CHAR(10), N''))), N''),
            TRAINING_CD = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(TRAINING_CD, CHAR(13), N''), CHAR(10), N''))), N''),
            FROM_DT     = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(FROM_DT, CHAR(13), N''), CHAR(10), N''))), N''),
            TO_DT       = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(TO_DT, CHAR(13), N''), CHAR(10), N''))), N''),
            TIME_STAMP  = NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(TIME_STAMP, CHAR(13), N''), CHAR(10), N''))), N'');

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
            TRAINER_3,
            TIME_STAMP
        )
        SELECT
            NULLIF(LTRIM(RTRIM(T.AGNT_CD)), N''),
            NULLIF(LTRIM(RTRIM(T.REG_NO)), N''),
            NULLIF(LTRIM(RTRIM(T.TRAINING_CD)), N''),
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(T.FROM_DT)), N''), 103),
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(T.TO_DT)), N''), 103),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(T.LAPSED_DAY)), N'')),
            NULLIF(LTRIM(RTRIM(T.VENUE)), N''),
            NULLIF(LTRIM(RTRIM(T.OTHER)), N''),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(T.RESULT)), N'')),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(T.DUR)), N'')),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(T.STATUS)), N'')),
            NULLIF(LTRIM(RTRIM(T.REMARKS)), N''),
            NULLIF(LTRIM(RTRIM(T.TRAINER_1)), N''),
            NULLIF(LTRIM(RTRIM(T.TRAINER_2)), N''),
            NULLIF(LTRIM(RTRIM(T.TRAINER_3)), N''),
            @UploadDate
        FROM #TrainingFile T;

        IF OBJECT_ID('tempdb..#AgentMap') IS NOT NULL
            DROP TABLE #AgentMap;

        CREATE TABLE #AgentMap
        (
            OldAgentCode NVARCHAR(255) NOT NULL,
            NewAgentCode NVARCHAR(255) NOT NULL
        );

        INSERT INTO #AgentMap
        (
            OldAgentCode,
            NewAgentCode
        )
        SELECT DISTINCT
            LTRIM(RTRIM(AGNT_CD)),
            LTRIM(RTRIM(NEW_AGENT_CODE))
        FROM #AgentFile
        WHERE NULLIF(LTRIM(RTRIM(AGNT_CD)), N'') IS NOT NULL
          AND NULLIF(LTRIM(RTRIM(NEW_AGENT_CODE)), N'') IS NOT NULL;

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
            COALESCE(NULLIF(LTRIM(RTRIM(S.NEW_AGENT_CODE)), N''), NULLIF(LTRIM(RTRIM(S.AGNT_CD)), N'')),
            NULLIF(LTRIM(RTRIM(S.AGNT_TYP_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_MGR_CD)), N''),
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.AGNT_ORIG_CNTRCT_DT)), N''), 103),
            NULLIF(LTRIM(RTRIM(S.AGNT_CLAS_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_AGREE_TYP_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_TITL_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_LAST_NM)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_GIV_NM)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_SEX_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.CVL_STAT_NM)), N''),
            NULLIF(LTRIM(RTRIM(S.NATNL_NM)), N''),
            CASE
                WHEN TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.AGNT_BTH_DT)), N''), 103) = CONVERT(DATE, '19000101')
                    THEN NULL
                ELSE TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.AGNT_BTH_DT)), N''), 103)
            END,
            NULLIF(LTRIM(RTRIM(S.AGNT_BTH_PLACE_TXT)), N''),
            NULLIF(LTRIM(RTRIM(S.RELIGION)), N''),
            NULLIF(LTRIM(RTRIM(S.CITY_ID)), N''),
            NULLIF(LTRIM(RTRIM(S.TAX_ID)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_LOC_CD)), N''),
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.MONT_LOC_STRT_DT)), N''), 103),
            NULLIF(LTRIM(RTRIM(S.DT_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.MPHOME)), N''),
            NULLIF(LTRIM(RTRIM(S.MPIN)), N''),
            NULLIF(LTRIM(RTRIM(S.EDUC_LVL_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.SCHOOL_NM)), N''),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(S.ATND_FROM_YR)), N'')),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(S.ATND_TO_YR)), N'')),
            NULLIF(LTRIM(RTRIM(S.EMPL_CO_NM)), N''),
            NULLIF(LTRIM(RTRIM(S.EMPL_POSN_NM)), N''),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(S.EMPL_FROM_YR)), N'')),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(S.EMPL_TO_YR)), N'')),
            NULLIF(LTRIM(RTRIM(S.EMAIL)), N''),
            NULLIF(LTRIM(RTRIM(S.MAIN_EMPL)), N''),
            NULLIF(LTRIM(RTRIM(S.TAX_MRD_STATUS)), N''),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(S.TAX_NUM_DPNDTS)), N'')),
            NULLIF(LTRIM(RTRIM(S.AGNT_BNK_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_BNK_ACCT_NUM)), N''),
            NULLIF(LTRIM(RTRIM(S.PROD_STATUS)), N''),
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.PROD_STAT_DT)), N''), 103),
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(S.RCV_DT)), N''), 103),
            NULLIF(LTRIM(RTRIM(S.BRANCH)), N''),
            NULLIF(LTRIM(RTRIM(S.EXP_FLAG)), N''),
            NULLIF(LTRIM(RTRIM(S.DIST_TYPE)), N'')
        FROM #AgentFile S
        WHERE COALESCE(NULLIF(LTRIM(RTRIM(S.NEW_AGENT_CODE)), N''), NULLIF(LTRIM(RTRIM(S.AGNT_CD)), N'')) IS NOT NULL
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.t_agnt_profile P
              WHERE P.agnt_cd = COALESCE(NULLIF(LTRIM(RTRIM(S.NEW_AGENT_CODE)), N''), NULLIF(LTRIM(RTRIM(S.AGNT_CD)), N''))
          );

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
            COALESCE(NULLIF(LTRIM(RTRIM(S.NEW_AGENT_CODE)), N''), NULLIF(LTRIM(RTRIM(S.AGNT_CD)), N'')),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT1_1)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT2_1)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT3_1)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_CITY_CD_1)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_MAIL_ADDR_PSTL_TXT_1)), N''),
            NULLIF(LTRIM(RTRIM(S.ADDR_TYP_CD_1)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_MAIL_FLG_1)), N'')
        FROM #AgentFile S
        WHERE COALESCE(NULLIF(LTRIM(RTRIM(S.NEW_AGENT_CODE)), N''), NULLIF(LTRIM(RTRIM(S.AGNT_CD)), N'')) IS NOT NULL
          AND
          (
              NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT1_1)), N'') IS NOT NULL
              OR NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT2_1)), N'') IS NOT NULL
              OR NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT3_1)), N'') IS NOT NULL
              OR NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_CITY_CD_1)), N'') IS NOT NULL
          );

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
            COALESCE(NULLIF(LTRIM(RTRIM(S.NEW_AGENT_CODE)), N''), NULLIF(LTRIM(RTRIM(S.AGNT_CD)), N'')),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT1_2)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT2_2)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT3_2)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_CITY_CD_2)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_MAIL_ADDR_PSTL_TXT_2)), N''),
            NULLIF(LTRIM(RTRIM(S.ADDR_TYP_CD_2)), N''),
            NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_MAIL_FLG_2)), N'')
        FROM #AgentFile S
        WHERE COALESCE(NULLIF(LTRIM(RTRIM(S.NEW_AGENT_CODE)), N''), NULLIF(LTRIM(RTRIM(S.AGNT_CD)), N'')) IS NOT NULL
          AND
          (
              NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT1_2)), N'') IS NOT NULL
              OR NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT2_2)), N'') IS NOT NULL
              OR NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_ST_TXT3_2)), N'') IS NOT NULL
              OR NULLIF(LTRIM(RTRIM(S.AGNT_ADDR_CITY_CD_2)), N'') IS NOT NULL
          );

        INSERT INTO dbo.t_agnt_dpndt
        (
            agnt_cd,
            rel_last_nm,
            rel_first_nm,
            birth_dt,
            rel_type
        )
        SELECT
            COALESCE(NULLIF(LTRIM(RTRIM(S.NEW_AGENT_CODE)), N''), NULLIF(LTRIM(RTRIM(S.AGNT_CD)), N'')),
            NULLIF(LTRIM(RTRIM(X.rel_last_nm)), N''),
            NULLIF(LTRIM(RTRIM(X.rel_first_nm)), N''),
            CASE
                WHEN TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(X.birth_dt)), N''), 103) = CONVERT(DATE, '19000101')
                    THEN NULL
                ELSE TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(X.birth_dt)), N''), 103)
            END,
            NULLIF(LTRIM(RTRIM(X.rel_type)), N'')
        FROM #AgentFile S
        CROSS APPLY
        (
            VALUES
            (S.DPND_LAST_NM, S.DPND_GIV_NM, S.DPND_BTH_DT, S.DPND_REL_CD),
            (S.DPND_LAST_NM_CHILD1, S.DPND_GIV_NM_CHILD1, S.DPND_BTH_DT_CHILD1, S.DPND_REL_CD_CHILD1),
            (S.DPND_LAST_NM_CHILD2, S.DPND_GIV_NM_CHILD2, S.DPND_BTH_DT_CHILD2, S.DPND_REL_CD_CHILD2),
            (S.DPND_LAST_NM_CHILD3, S.DPND_GIV_NM_CHILD3, S.DPND_BTH_DT_CHILD3, S.DPND_REL_CD_CHILD3)
        ) X (rel_last_nm, rel_first_nm, birth_dt, rel_type)
        WHERE COALESCE(NULLIF(LTRIM(RTRIM(S.NEW_AGENT_CODE)), N''), NULLIF(LTRIM(RTRIM(S.AGNT_CD)), N'')) IS NOT NULL
          AND
          (
              NULLIF(LTRIM(RTRIM(X.rel_last_nm)), N'') IS NOT NULL
              OR NULLIF(LTRIM(RTRIM(X.rel_first_nm)), N'') IS NOT NULL
              OR NULLIF(LTRIM(RTRIM(X.rel_type)), N'') IS NOT NULL
          );

        INSERT INTO dbo.t_agnt_rltn
        (
            agnt_cd,
            rel_agnt_cd,
            rel_cd
        )
        SELECT
            COALESCE(NULLIF(LTRIM(RTRIM(S.NEW_AGENT_CODE)), N''), NULLIF(LTRIM(RTRIM(S.AGNT_CD)), N'')),
            NULLIF(LTRIM(RTRIM(S.REL_AGNT_CD)), N''),
            NULLIF(LTRIM(RTRIM(S.REL_CD)), N'')
        FROM #AgentFile S
        WHERE COALESCE(NULLIF(LTRIM(RTRIM(S.NEW_AGENT_CODE)), N''), NULLIF(LTRIM(RTRIM(S.AGNT_CD)), N'')) IS NOT NULL
          AND
          (
              NULLIF(LTRIM(RTRIM(S.REL_AGNT_CD)), N'') IS NOT NULL
              OR NULLIF(LTRIM(RTRIM(S.REL_CD)), N'') IS NOT NULL
          );

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
            trainer_3,
            time_stamp
        )
        SELECT
            COALESCE(NULLIF(LTRIM(RTRIM(A.NEW_AGENT_CODE)), N''), NULLIF(LTRIM(RTRIM(T.AGNT_CD)), N'')),
            NULLIF(LTRIM(RTRIM(T.REG_NO)), N''),
            NULLIF(LTRIM(RTRIM(T.TRAINING_CD)), N''),
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(T.FROM_DT)), N''), 103),
            TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(T.TO_DT)), N''), 103),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(T.LAPSED_DAY)), N'')),
            NULLIF(LTRIM(RTRIM(T.VENUE)), N''),
            NULLIF(LTRIM(RTRIM(T.OTHER)), N''),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(T.RESULT)), N'')),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(T.DUR)), N'')),
            TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(T.STATUS)), N'')),
            NULLIF(LTRIM(RTRIM(T.REMARKS)), N''),
            NULLIF(LTRIM(RTRIM(T.TRAINER_1)), N''),
            NULLIF(LTRIM(RTRIM(T.TRAINER_2)), N''),
            NULLIF(LTRIM(RTRIM(T.TRAINER_3)), N''),
            @UploadDate
        FROM #TrainingFile T
        OUTER APPLY
        (
            SELECT TOP (1)
                A.NEW_AGENT_CODE
            FROM #AgentFile A
            WHERE NULLIF(LTRIM(RTRIM(A.AGNT_CD)), N'') = NULLIF(LTRIM(RTRIM(T.AGNT_CD)), N'')
        ) A
        WHERE NULLIF(LTRIM(RTRIM(T.TRAINING_CD)), N'') IS NOT NULL
          AND COALESCE(NULLIF(LTRIM(RTRIM(A.NEW_AGENT_CODE)), N''), NULLIF(LTRIM(RTRIM(T.AGNT_CD)), N'')) IS NOT NULL;

        INSERT INTO dbo.t_log
        (
            agnt_cd,
    
            user_id,
            type,
            mode,
            date_stamp
        )
        SELECT DISTINCT
            NULLIF(LTRIM(RTRIM(S.AGNT_CD)), N''),
   
            N'SYS',
            N'INPUT',
            N'New',
            @UploadDate
        FROM #AgentFile S;

        COMMIT TRANSACTION;

        SELECT
            CAST(1 AS BIT) AS success,
            N'Import berhasil.' AS message,
            @UploadDate AS upload_date,
            (SELECT COUNT(*) FROM #AgentFile) AS agent_file_count,
            (SELECT COUNT(*) FROM #TrainingFile) AS training_file_count;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO