Config = {}

Config.framework = 'RSG' -- RSG

Config.SmallCamp = {
    ItemName      = 'small_camp_kit',    
    MaxPerPlayer  = 1,              
    DeleteOnQuit  = true,          

    PreviewDistance = 2.0,        
    PlaceKey        = 0xCEFD9220,   
    CancelKey       = 0x156F7119,   
    RemoveRadius    = 3.0,          

    MinDistanceBetweenCamps = 3.0,
}

Config.MidCamp = {
    ItemName      = 'med_camp_kit',    
    MaxPerPlayer  = 1,              
    DeleteOnQuit  = true,          

    PreviewDistance = 2.0,        
    PlaceKey        = 0xCEFD9220,   
    CancelKey       = 0x156F7119,   
    RemoveRadius    = 4.0,          

    MinDistanceBetweenCamps = 6.0,
}

Config.ProCamp = {
    ItemName      = 'pro_camp_kit',    
    MaxPerPlayer  = 1,              
    DeleteOnQuit  = false,          

    PreviewDistance = 2.0,        
    PlaceKey        = 0xCEFD9220,   
    CancelKey       = 0x156F7119,   
    RemoveRadius    = 5.0,          

    MinDistanceBetweenCamps = 10.0,
}

Config.SmallCampProps = {
    {
        name     = 'fire',
        model    = 'p_campfire05x',
        offset   = vector3(0.0, 0.0, 0.0), 
        heading  = 0.0,
        freeze   = true,
        isCenter = true
    },
    {
        name    = 'chair1',
        model   = 'p_ambchair01x',
        offset  = vector3(1.3, 0.3, 0.0),  
        heading = -100.0,
        freeze  = true
    },
    {
        name    = 'chair1',
        model   = 'p_ambchair01x',
        offset  = vector3(1.0, -1.7, 0.0),  
        heading = -130.0,
        freeze  = true
    },
    {
        name    = 'bedroll',
        model   = 'p_bedrollopen03x',
        offset  = vector3(-1.9, -0.4, 0.0), 
        heading = 0.0,
        freeze  = true
    },
    {
        name    = 'lantern',
        model   = 'p_lantern05x',
        offset  = vector3(0.2, 1.4, 0.0),
        heading = 0.0,
        freeze  = true
    },
}

Config.MidCampProps = {
    {
        name     = 'fire',
        model    = 'p_campfire05x',
        offset   = vector3(0.0, 0.0, 0.0), 
        heading  = 0.0,
        freeze   = true,
        isCenter = true
    },
     {
        name    = 'chair1',
        model   = 'p_ambchair01x',
        offset  = vector3(1.4, 0.4, 0.0),  
        heading = -70.0,
        freeze  = true
    },
    {
        name    = 'chair2',
        model   = 'p_ambchair01x',
        offset  = vector3(1.1, -0.9, 0.0),  
        heading = -130.0,
        freeze  = true
    },
   {
        name    = 'bedroll',
        model   = 'p_bedrollopen03x',
        offset  = vector3(5.0, 6.8, 0.0), 
        heading = -61.0,
        freeze  = true
    },
    {
        name    = 'bedroll2',
        model   = 'p_bedrollopen03x',
        offset  = vector3(6.5, 4.2, 0.0), 
        heading = -61.0,
        freeze  = true
    },
    {
        name    = 'bag1',
        model   = 'p_ambpack01x',
        offset  = vector3(5.2, 3.0, 0.0), 
        heading = -145.0,
        freeze  = true
    },
    {
        name    = 'food1',
        model   = 's_canpeaches01x',
        offset  = vector3(4.8, 2.6, 0.0), 
        heading = -140.0,
        freeze  = true
    },
    {
        name    = 'food2',
        model   = 's_canpeaches01x',
        offset  = vector3(4.7, 2.5, 0.0), 
        heading = -140.0,
        freeze  = true
    },
    
    {
        name    = 'lantern',
        model   = 'p_lantern05x',
        offset  = vector3(6.8, 6.0, 0.0),
        heading = 0.0,
        freeze  = true
    },
         {
        name    = 'tent',
        model   = 'p_tentnorth01x',
        offset  = vector3(5.0, 5.0, 0.0),
        heading = -60.0,
       
     },
}

Config.ProCampProps = {
    {
        name     = 'fire',
        model    = 'p_campfire05x',
        offset   = vector3(0.0, 0.0, 0.0), 
        heading  = 0.0,
        freeze   = true,
        isCenter = true
    },
    {
        name    = 'chair1',
        model   = 'p_ambchair01x',
        offset  = vector3(1.4, 0.4, 0.0),  
        heading = -70.0,
        freeze  = true
    },
    {
        name    = 'chair2',
        model   = 'p_ambchair01x',
        offset  = vector3(1.1, -0.9, 0.0),  
        heading = -130.0,
        freeze  = true
    },
    {
        name    = 'chair3',
        model   = 'p_ambchair01x',
        offset  = vector3(0.5, 1.5, 0.0),  
        heading = -25.0,
        freeze  = true
    },
    {
        name    = 'chair4',
        model   = 'p_ambchair01x',
        offset  = vector3(0.0, 6.1, 0.0),  
        heading = -35.0,
        freeze  = true
    },
    {
        name    = 'crate',
        model   = 'p_cratefloat01x',
        offset  = vector3(-1.0, 6.2, 0.0),  
        heading = -110.0,
        freeze  = true
    },
   
    {
        name    = 'bedroll',
        model   = 'p_bedrollopen03x',
        offset  = vector3(5.0, 6.8, 0.0), 
        heading = -61.0,
        freeze  = true
    },
    {
        name    = 'bedroll2',
        model   = 'p_bedrollopen03x',
        offset  = vector3(6.5, 4.2, 0.0), 
        heading = -61.0,
        freeze  = true
    },
    {
        name    = 'bag1',
        model   = 'p_ambpack01x',
        offset  = vector3(5.2, 3.0, 0.0), 
        heading = -145.0,
        freeze  = true
    },
    {
        name    = 'food1',
        model   = 's_canpeaches01x',
        offset  = vector3(4.8, 2.6, 0.0), 
        heading = -140.0,
        freeze  = true
    },
    {
        name    = 'food2',
        model   = 's_canpeaches01x',
        offset  = vector3(4.7, 2.5, 0.0), 
        heading = -140.0,
        freeze  = true
    },
    
    {
        name    = 'lantern',
        model   = 'p_lantern05x',
        offset  = vector3(6.8, 6.0, 0.0),
        heading = 0.0,
        freeze  = true
    },
         {
        name    = 'tent',
        model   = 'p_tentnorth01x',
        offset  = vector3(5.0, 5.0, 0.0),
        heading = -60.0,
       
     },
      {
        name    = 'tent2',
        model   = 'p_tentnorth01x',
        offset  = vector3(7.3, 0.4, 0.0),
        heading = -66.0,
       
     },
     {
        name    = 'bedrol3',
        model   = 'p_bedrollopen03x',
        offset  = vector3(7.2, 1.9, 0.0), 
        heading = -65.0,
        freeze  = true
    },
    {
        name    = 'bedroll4',
        model   = 'p_bedrollopen03x',
        offset  = vector3(8.3, -0.8, 0.0), 
        heading = -65.0,
        freeze  = true
    },
    {
        name    = 'bag2',
        model   = 'p_ambpack01x',
        offset  = vector3(6.9, -1.8, 0.0), 
        heading = -150.0,
        freeze  = true
    },
    {
        name    = 'food3',
        model   = 's_canpeaches01x',
        offset  = vector3(6.5, -2.1, 0.0), 
        heading = -140.0,
        freeze  = true
    },
    {
        name    = 'food4',
        model   = 's_canpeaches01x',
        offset  = vector3(6.5, -2.0, 0.0), 
        heading = -140.0,
        freeze  = true
    },
    
    {
        name    = 'lantern2',
        model   = 'p_lantern05x',
        offset  = vector3(9.25, 1.2, 0.0),
        heading = 0.0,
        freeze  = true
    },
    {
        name    = 'hitch1',
        model   = 'p_hitchingpost01x',
        offset  = vector3(3.25, -6.0 , 0.0),
        heading = 30.0,
        freeze  = true
    },
    {
        name    = 'hitch2',
        model   = 'p_hitchingpost01x',
        offset  = vector3(0.4, -6.8 , 0.0),
        heading = 2.0,
        freeze  = true
    },
      
      
}