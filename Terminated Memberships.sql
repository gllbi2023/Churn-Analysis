SELECT M.Id,
           [User_id],
           ROUND(DATEDIFF(YEAR, U.Date_of_birth, 
                   LEAST(GETDATE(), M.[ExpiryDate])), 0) AS MemberAge,
           U.Gender,
           E.EthnicGroup AS Ethnicity,
           CASE 
               WHEN U.Disability LIKE '%No%' THEN 'No'
               WHEN U.Disability is null THEN null
               ELSE 'Yes'
           END AS IsDisabled,
           M.Membership,
           M.[MembershipType],
           CASE WHEN M.MembershipType LIKE '%Centre%' THEN 'Centre'
                WHEN M.MembershipType LIKE '%Partnership%' THEN 'Partnership'
                WHEN M.MembershipType LIKE '%UK%' THEN 'National'
                ELSE 'Other'
            END AS MembershipScope,
           CASE WHEN EligibilityType LIKE 'GP Referral%' THEN 'GP Referral'
                WHEN EligibilityType LIKE 'Senior%' THEN 'Senior'
                WHEN EligibilityType = 'Sport Foundation Athlete' THEN 'GSF'
                WHEN EligibilityType IS NULL THEN 'None'
                ELSE EligibilityType
            END AS DiscountType,
           CASE WHEN EligibilityType IS NULL THEN 'No'
                ELSE 'Yes'
            END AS IsDiscounted, 
           ROUND(DATEDIFF(DAY, StartDate, 
                  CASE WHEN M.BillingType = 'fixed' THEN M.[ExpiryDate] 
                       ELSE MS.applies_from
                  END) / 30.4167, 0) AS LengthOfStayInMonths,
           P.Persona,
           P.IMD10,
           P.output_area_classification_supergroup,
           reason AS TerminationReason
FROM [dbo].[vw_Memberships] M 
LEFT JOIN dbo.Flow_Customers U on U.Id = M.User_id
LEFT JOIN EthnicityData E ON E.GLLEthnicity = U.Ethnicity
LEFT JOIN PostCodeData P ON P.postcode = U.Postcode
LEFT JOIN MembershipsProduct MP ON MP.MembershipType = M.MembershipType
LEFT JOIN Flow_MembershipStatus MS ON MS.membership_id = M.Id AND MS.[status] = 'cancelled'
WHERE M.[Status] != 'active' 
    AND (MS.applies_from IS NOT NULL OR M.ExpiryDate IS NOT NULL)
    AND MP.MembershipCategory = 'Prepaid'