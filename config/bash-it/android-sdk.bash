# android

ANDROID_SDK_HOME=/opt/google/android-sdk-linux
ANDROID_HOME=$ANDROID_SDK_HOME
PATH=$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

export ANDROID_SDK_HOME ANDROID_HOME

GOOGLE_CLOUD_SDK_HOME=/opt/google/google-cloud-sdk
if test -d $GOOGLE_CLOUD_SDK_HOME ; then
    . $GOOGLE_CLOUD_SDK_HOME/env.sh
fi

export GOOGLE_CLOUD_SDK_HOME

APPENGINE_HOME=$GOOGLE_CLOUD_SDK_HOME/platform/google_appengine/google/appengine/tools/java

export APPENGINE_HOME
