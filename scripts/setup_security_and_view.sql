-- ====================================================================
-- FDE ENTERPRISE SECURITY & SEMANTIC LAYER SCRIPT (single-line version)
-- Purpose: Protect the legacy DB from LLM hallucinations and mutations
-- Rewritten so each statement is one line, safe for DB Navigator's
-- in-app executor (no GO, no comma-split multi-permission statements).
-- Safe to re-run: schema/view/login/user are guarded with existence checks.
-- ====================================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'FDE_VIEWS') EXEC('CREATE SCHEMA FDE_VIEWS');

IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'VW_ACTIVE_FLEET' AND SCHEMA_NAME(schema_id) = 'FDE_VIEWS') EXEC('DROP VIEW FDE_VIEWS.VW_ACTIVE_FLEET');

EXEC('CREATE VIEW FDE_VIEWS.VW_ACTIVE_FLEET AS SELECT TS_UTC AS [Timestamp], V_LAT AS [Latitude], V_LON AS [Longitude], CAST(IOT_TEMP_VAL_C AS FLOAT) AS [Current_Temperature_C], CGO_COND_CD AS [Cargo_Condition_Code], RISK_CLS_TXT AS [Risk_Classification], DELAY_PROB_DEC AS [Delay_Probability], PRT_CNG_LVL AS [Port_Congestion_Level], RT_RSK_IDX AS [Route_Risk_Index] FROM dbo.TBL_SC_FLEET_HIST_RAW');

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'USR_FDE_RO') CREATE LOGIN USR_FDE_RO WITH PASSWORD = 'AgentPassword2026!';

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'USR_FDE_RO') CREATE USER USR_FDE_RO FOR LOGIN USR_FDE_RO;

GRANT SELECT ON FDE_VIEWS.VW_ACTIVE_FLEET TO USR_FDE_RO;

DENY SELECT ON dbo.TBL_SC_FLEET_HIST_RAW TO USR_FDE_RO;

DENY INSERT ON SCHEMA::dbo TO USR_FDE_RO;

DENY UPDATE ON SCHEMA::dbo TO USR_FDE_RO;

DENY DELETE ON SCHEMA::dbo TO USR_FDE_RO;

DENY ALTER ON SCHEMA::dbo TO USR_FDE_RO;

-- # About the DENY ... ON SCHEMA::dbo lines:
-- dbo (Database Owner) is the default schema where your Python ingestion
-- script dumped TBL_SC_FLEET_HIST_RAW. Denying at the SCHEMA level applies
-- the rule to every current table/view in dbo, and any added there later.