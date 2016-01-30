﻿<#
.Synopsis
	WingtipTickets (WTT) Demo Environment.
.DESCRIPTION
	This script is used to edit the Application Settings values of the web.config file in the Azure WebSites WebDeploy Zip Package.
.EXAMPLE
	Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName <string> -AzureWebSiteWebDeployPackageName <string> -SearchServicePrimaryManagementKey <string>
#>
function Set-WTTEnvironmentWebConfig
{
	[CmdletBinding()]
	Param
	(
		# WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$WTTEnvironmentApplicationName,

		# WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$Websitename,

		# Primary Azure SQL Database Server Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseServerPrimaryName,

		# Secondary Azure SQL Database Server Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseServerSecondaryName,

		# Azure SQL Database Server Administrator User Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseServerAdministratorUserName,

		# Azure SQL Database Server Adminstrator Password
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseServerAdministratorPassword,

		# Azure SQL Database Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseName,

		# Path to Azure Web Site WebDeploy Package
		[Parameter(Mandatory = $false)] 
		[String]$AzureWebSiteWebDeployPackagePath, 

		# Azure Search Service Primary Management Key
		[Parameter(Mandatory = $true)] 
		[String]$SearchServicePrimaryManagementKey,

		# Azure DocumentDb Name
		[Parameter(Mandatory = $false)]
		[String]$azureDocumentDbName,

		# Azure DocumentDb Key
		[Parameter(Mandatory = $false)] 
		[String]$documentDbPrimaryKey
	)

	Process
	{
		try
		{
			WriteLabel("Setting Config Settings")

			# Check Defaults
			if($AzureSqlDatabaseServerAdministratorUserName -eq "")
			{
				$AzureSqlDatabaseServerAdministratorUserName = "developer"
			}

			if($AzureSqlDatabaseServerAdministratorPassword -eq "")
			{
				$AzureSqlDatabaseServerAdministratorPassword = "P@ssword1"
			}

			if($AzureSqlDatabaseName -eq "")
			{
				$AzureSqlDatabaseName = "Customer1"
			}


			$ADFWebSite = (Find-AzureRmResource -ResourceType Microsoft.Web/sites -ResourceNameContains "recommendations" -ExpandProperties).Name

			if ($ADFWebSite -like "*recommendations*")
			{
				$ADFWebSite = [string](get-azurermwebapp -name $ADFWebsite).HostNames
			}
			else
			{
				$adfwebsite ="ProductRecWebAppMissing"
			}

			# Build web application settings
			$settings = New-Object Hashtable
			$settings = 
			@{
				    "TenantName" = "$WTTEnvironmentApplicationName"; 
					"DatabaseUserName" = "$AzureSqlDatabaseServerAdministratorUserName"; 
					"DatabaseUserPassword" = "$AzureSqlDatabaseServerAdministratorPassword"; 
					"PrimaryDatabaseServer" = "$AzureSqlDatabaseServerPrimaryName"; 
					"SecondaryDatabaseServer" = "$AzureSqlDatabaseServerSecondaryName"; 
					"TenantDbName" = "$AzureSqlDatabaseName"; 
					"SearchServiceKey" = "$SearchServicePrimaryManagementKey"; 
					"SearchServiceName" = "$wTTEnvironmentApplicationName"; 
					"DocumentDbServiceEndpointUri" = ("https://$DocumentDbName.documents.azure.com:443/"); 
					"DocumentDbServiceAuthorizationKey" = "$DocumentDbKey";
					"RecommendationSiteUrl" = "$ADFWebSite";
			}

			# Add the settings to the website
			$null = Set-AzureRMWebApp -AppSettings $settings -Name $websiteName -ResourceGroupName $WTTEnvironmentApplicationName

			# Restart the website - (Not sure that this is needed, try without first)
			Restart-AzureRMWebApp -Name $websiteName -ResourceGroupName $WTTEnvironmentApplicationName
			
			WriteValue("Successful")
		}
		catch
		{
			WriteError($Error)
		}
	}
}

