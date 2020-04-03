#include "plugin.h"

enum plugin_status plugin_start(const void* parameter)
{
    (void)parameter;
    rb->rmdir("/AUDIBLE");
    rb->rmdir("/AUDIOBOOKS");
    rb->rmdir("/PODCASTS");
    rb->rmdir("/RECORD/FM");
    rb->rmdir("/RECORD/VOICE");
    rb->rmdir("/RECORD");
    rb->remove("/##PORT#/DeviceIcon.ico");
    rb->remove("/##PORT#/Object.dat");
    rb->remove("/##PORT#/nonce.bin");
    rb->remove("/##PORT#/sample.hds");
    rb->rmdir("/##PORT#");
    rb->rmdir("/##MUSIC#/Audiobooks");
    rb->rmdir("/##MUSIC#/Music");
    rb->rmdir("/##MUSIC#/Playlists");
    rb->rmdir("/##MUSIC#/Podcasts");
    rb->rmdir("/##MUSIC#/Service/Rhapsody/Artist");
    rb->rmdir("/##MUSIC#/Service/Rhapsody/Playlists");
    rb->remove("/##MUSIC#/Service/Rhapsody/addtolibrary.dat");
    rb->remove("/##MUSIC#/Service/Rhapsody/radiopc.txt");
    rb->remove("/##MUSIC#/Service/Rhapsody/ratings.dat");
    rb->rmdir("/##MUSIC#/Service/Rhapsody");
    rb->rmdir("/##MUSIC#/Service");
    rb->remove("/##MUSIC#/capabilities.xml");
    rb->rmdir("/##MUSIC#");
    rb->splash(HZ*1, "byteframe");
    return PLUGIN_OK;
}
