SELECT M.Id, M.[User_id], COUNT(Visits) * 1.0 / 
                  NULLIF((DATEDIFF(DAY, StartDate, 
                  CASE WHEN M.BillingType = 'fixed' THEN M.[ExpiryDate] 
                       ELSE MS.applies_from
                  END) / 30.4167), 0) AS VisitsPerMonth
FROM [dbo].[vw_Memberships] M 
LEFT JOIN MembershipsProduct MP ON MP.MembershipType = M.MembershipType
LEFT JOIN Flow_MembershipStatus MS ON MS.membership_id = M.Id AND MS.[status] = 'cancelled'
LEFT JOIN CustomerVisits V ON M.User_id = V.User_id AND V.Date BETWEEN M.StartDate AND CASE WHEN M.BillingType = 'fixed' THEN M.[ExpiryDate] ELSE MS.applies_from END
WHERE M.[Status] != 'active' 
    AND (MS.applies_from IS NOT NULL OR M.ExpiryDate IS NOT NULL)
    AND MP.MembershipCategory = 'Prepaid'
GROUP BY M.ID, M.User_id,(DATEDIFF(DAY, StartDate, 
                  CASE WHEN M.BillingType = 'fixed' THEN M.[ExpiryDate] 
                       ELSE MS.applies_from
                  END) / 30.4167)