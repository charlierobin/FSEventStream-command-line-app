//
//  main.m
//  FSEVents
//
//  Created by charlie 21/4/2016

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

static FSEventStreamRef g_Stream = NULL;

static NSDictionary *flagsToDictionary( FSEventStreamEventFlags flags )
{
    NSMutableDictionary *result = [ NSMutableDictionary dictionary ];

    #define ADD_FLAG(name) \
        if (flags & kFSEventStreamEventFlag##name) \
            result[@#name] = @YES;

    ADD_FLAG(MustScanSubDirs)
    ADD_FLAG(UserDropped)
    ADD_FLAG(KernelDropped)
    ADD_FLAG(EventIdsWrapped)
    ADD_FLAG(HistoryDone)
    ADD_FLAG(RootChanged)
    ADD_FLAG(Mount)
    ADD_FLAG(Unmount)
    ADD_FLAG(ItemCreated)
    ADD_FLAG(ItemRemoved)
    ADD_FLAG(ItemInodeMetaMod)
    ADD_FLAG(ItemRenamed)
    ADD_FLAG(ItemModified)
    ADD_FLAG(ItemFinderInfoMod)
    ADD_FLAG(ItemChangeOwner)
    ADD_FLAG(ItemXattrMod)
    ADD_FLAG(ItemIsFile)
    ADD_FLAG(ItemIsDir)
    ADD_FLAG(ItemIsSymlink)
    ADD_FLAG(OwnEvent)
    ADD_FLAG(ItemIsHardlink)
    ADD_FLAG(ItemIsLastHardlink)
    ADD_FLAG(ItemCloned)

    #undef ADD_FLAG

    return result;
}

void callbackHandler( ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[] )
{
    @autoreleasepool
    {
        char **paths = eventPaths;
        
        for ( size_t i = 0; i < numEvents; i++ )
        {
            NSString *path = [ NSString stringWithUTF8String:paths[ i ] ];
            
            if ( path == nil ) continue;
            
            NSDictionary *event = @{
                
                @"path": path,
                
                // in the Xojo JSON parser, these integers seem to cause trouble
                // so here I'm just emitting them as strings instead
                // (as I really don’t care about the event IDs, they are just here for the sake of completeness)
                
                // @"id": @( eventIds[ i ] ),
                
                @"id": [ NSString stringWithFormat: @"%llu", ( unsigned long long )eventIds[ i ] ],
                
                @"flags": flagsToDictionary( eventFlags[ i ] )
            };
            
            NSError *error = nil;
            
            NSData *json = [ NSJSONSerialization dataWithJSONObject: event options:NSJSONWritingFragmentsAllowed error: &error ];
            
            if ( json == nil ) continue;
            
            fwrite( json.bytes, 1, json.length, stdout );
            fputc( '\n', stdout );
            fflush( stdout );
        }
    }
}

int main( int argc, const char * argv[] )
{
    @autoreleasepool
    {
        if (argc < 2)
        {
            fprintf( stderr, "Usage: FSEvents <path> [path ...]\n" );
            return 1;
        }
        
        NSMutableArray *paths = [ NSMutableArray array ];
        
        for ( int i = 1; i < argc; i++ )
        {
            NSString *path = [ NSString stringWithUTF8String:argv[ i ] ];
            
            if ( path != nil ) [ paths addObject: path ];
        }
        
        if ( paths.count == 0 ) return 1;
        
        CFArrayRef pathsToWatch = ( __bridge CFArrayRef )paths;
        
        FSEventStreamContext context = { 0 };
        
        g_Stream = FSEventStreamCreate( NULL, &callbackHandler, &context, pathsToWatch, kFSEventStreamEventIdSinceNow, 0.5, kFSEventStreamCreateFlagFileEvents );
        
        if ( g_Stream == NULL )
        {
            fprintf( stderr, "Unable to create FSEvent stream\n" );
            return 1;
        }
        
        FSEventStreamScheduleWithRunLoop( g_Stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode );
        
        if (!FSEventStreamStart( g_Stream ))
        {
            fprintf( stderr, "Unable to start FSEvent stream\n" );
            
            FSEventStreamInvalidate( g_Stream );
            FSEventStreamRelease( g_Stream );
            g_Stream = NULL;
            
            return 1;
        }
        
        fprintf( stderr, "Watching %lu path(s)\n", ( unsigned long )paths.count );
        
        CFRunLoopRun();
        
        // only get here if the run loop is stopped
        // which is not going to happen in this app, even with SIGINT or similar
        // so the below is not needed
        // but this is how the stream would be shut down if required
        
        FSEventStreamStop( g_Stream );
        FSEventStreamInvalidate( g_Stream );
        FSEventStreamRelease( g_Stream );
        
        return 0;
    }
}


