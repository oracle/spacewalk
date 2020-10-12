package com.redhat.rhn.yaml.modulemd;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.manager.channel.ChannelManager;

import org.apache.log4j.Logger;

import org.yaml.snakeyaml.Yaml;
import org.yaml.snakeyaml.DumperOptions;

/**
 * ModuleYamlManager - Class that deals with de/serializing modulemd YAML
 * documents found in modules.yaml files to/from {@link Module} entities.
 */
public final class ModuleYamlManager {

    private static Logger log = Logger.getLogger(ModuleYamlManager.class);

    private ModuleYamlManager() {
    }

    private static <T> T getMapEntry(Map<String, T> entry, String key, boolean toString) {
        T entryVal = null;

        if (entry.get(key) != null) {
            entryVal = entry.get(key);
            if (toString) {
                entryVal = (T) entryVal.toString();
            }
        }

        return entryVal;
    }

    /**
     * Get an Iterator over modulemd YAML documents for the provided Channel's modules.yaml file.
     * The Iterator provides Objects that should be converted to Modules via createModuleFromYamlDoc()
     * @param c the {@link Channel} for which to get {@link Module}
     * @throws FileNotFoundException when modules.yaml not found
     * @return an Iterable of {@link Module}
     */
    public static Iterable<Object> getModuleIter(Channel c)
        throws FileNotFoundException {
        if (c.getModules() == null) {
            return null;
        }

        return getModuleIter(c.getModules().getFQFilename());
    }

    /**
     * Get an Iterator over modulemd YAML documents for the provided Channel's modules.yaml file.
     * The Iterator provides Objects that should be converted to Modules via createModuleFromYamlDoc()
     * @param cid the channel id for the channel for which to get {@link Module}
     * @throws FileNotFoundException when modules.yaml not found
     * @return an Iterable of {@link Module}
     */
    public static Iterable<Object> getModuleIter(Long cid)
        throws FileNotFoundException {
        Channel c = ChannelFactory.lookupById(cid);
        return getModuleIter(c);
    }

    /**
     * Get an Iterator over modulemd YAML documents for the provided Channel's modules.yaml file.
     * The Iterator provides Objects that should be converted to Modules via createModuleFromYamlDoc()
     * @param modulesYamlFilePath the path to the modules file
     * @throws FileNotFoundException when modules.yaml not found
     * @return an Iterable of {@link Module}
     */
    public static Iterable<Object> getModuleIter(String modulesYamlFilePath)
        throws FileNotFoundException {
        File yamlFile = new File(modulesYamlFilePath);

        try {
            InputStream input = new FileInputStream(yamlFile);
            Yaml yaml = new Yaml();
            return yaml.loadAll(input);
        }
        catch (FileNotFoundException e) {
            String errMsg = "Unable to open " + modulesYamlFilePath;
            log.error(errMsg, e);
            throw e;
        }
    }

    /**
     * Get a Set of {@link Module} for the Channel's modules.yaml file.
     * @param c the {@link Channel} for which to get {@link Module}
     * @throws FileNotFoundException when modules.yaml not found
     * @return a Set of {@link Module}
     */
    public static Set<Module> getModuleSet(Channel c)
        throws FileNotFoundException {
        if (c.getModules() == null) {
            return null;
        }

        return getModulesSet(c.getModules().getFQFilename());
    }

    /**
     * Get a Set of {@link Module} for the Channel's modules.yaml file.
     * @param cid the channel id for the channel for which to get Module
     * @throws FileNotFoundException when modules.yaml not found
     * @return a Set of {@link com.redhat.rhn.domain.channel.Modules}
     */
    public static Set<Module> getModuleSet(Long cid)
        throws FileNotFoundException {
        Channel c = ChannelFactory.lookupById(cid);
        return getModuleSet(c);
    }

    /**
     * Get a Set of {@link Module} for the Channel's modules.yaml file.
     * @param modulesYamlFilePath the path to the modules file
     * @throws FileNotFoundException when modules.yaml not found
     * @return a Set of {@link com.redhat.rhn.domain.channel.Modules}
     */
    public static Set<Module> getModulesSet(String modulesYamlFilePath)
        throws FileNotFoundException {
        Set<Module> moduleSet = new HashSet<Module>();
        for (Object yamlModuleDoc : getModuleIter(modulesYamlFilePath)) {
            moduleSet.add(createModuleFromYamlDoc(yamlModuleDoc));
        }
        return moduleSet;
    }

    /**
     * Create a {@link ModuleYamlManager} from an Object serialized from a modules.yaml file.
     * @param yamlDoc the document loaded from yaml file
     * @return the Module parse from the yaml document
     */
    public static Module createModuleFromYamlDoc(Object yamlDoc) {
        Module module = new Module();
        Map<String, ?> mapEntry;

        mapEntry = (Map<String, ?>)((Map<String, ?>) yamlDoc).get("data");
        if (mapEntry != null) {
            module.setName((String) getMapEntry(mapEntry, "name", false));
            module.setStream((String) getMapEntry(mapEntry, "stream", true));

            module.setVersion((Long) getMapEntry(mapEntry, "version", false));
            module.setContext((String) getMapEntry(mapEntry, "context", true));
            module.setArch((String) getMapEntry(mapEntry, "arch", false));
            module.setSummary((String) getMapEntry(mapEntry, "summary", false));
            module.setDescription((String) getMapEntry(mapEntry, "description", false));

            mapEntry = (Map<String, ?>) mapEntry.get("artifacts");

            if (mapEntry != null) {
                module.setRpms((ArrayList<String>) getMapEntry(mapEntry, "rpms", false));
            }
        }

        return module;
    }

    /**
     * Add a Set of {@link Module} to the destination Channel's modules.yaml file.
     * This is performed by finding the modulemd documents in the source source
     * Channel's modules.yaml file that match those in the provided {@link Module} Set,
     * and copying them to the Channel's modules.yaml file.
     * This approach is taken instead of directly serializing the {@link Module} Set because
     * only a subset of the modulemd document is modelled in the entity object.
     * @param moduleSet the modules to add to destination modules.yaml file
     * @param sourceChan the source Channel
     * @param destChan the destination Channel
     * @throws FileNotFoundException if either source or destionation modules.yaml file is missing
     * @throws IOException if destination modules.yaml file canoot be written to
     */
    public static void addModulesToYamlFile(Set<Module> moduleSet, Channel sourceChan, Channel destChan)
        throws FileNotFoundException, IOException {
        HashSet<Object> missingModules = new HashSet<Object>();

        // Our domain model doesn't map the complete modulemd schema, so have to
        // copy raw yaml instead of serializing our domain model Module objects.
        for (Object sourceYamlDoc : getModuleIter(sourceChan)) {
            Module sourceModule = createModuleFromYamlDoc(sourceYamlDoc);
            if (moduleSet.contains(sourceModule)) {
                missingModules.add(sourceYamlDoc);
            }
        }

        if (!missingModules.isEmpty()) {
            String modulesYamlFilePath = destChan.getModules().getFQFilename();
            File yamlFile = new File(modulesYamlFilePath);

            DumperOptions options = new DumperOptions();
            // https://yaml.org/spec/current.html#id2509255
            options.setDefaultFlowStyle(DumperOptions.FlowStyle.BLOCK);
            options.setExplicitStart(true);
            Yaml yaml = new Yaml(options);

            FileWriter fw = null;
            try {
                fw = new FileWriter(yamlFile, true);
                yaml.dumpAll(missingModules.iterator(), fw);
            }
            catch (FileNotFoundException e) {
                String errMsg = "Unable to open " + modulesYamlFilePath;
                log.error(errMsg, e);
                throw e;
            }
            catch (IOException e) {
                String errMsg = "Unable to write to " + modulesYamlFilePath;
                log.error(errMsg, e);
                throw e;
            }
            finally {
                if (fw != null) {
                    try {
                        fw.close();
                    }
                    catch (IOException e) {
                        String errMsg = "Unable to flush and close " + modulesYamlFilePath;
                        log.error(errMsg, e);
                        throw e;
                    }
                }
            }

            // Schedule repomd regen to regenerate modules.yaml checksum
            ChannelManager.queueChannelChange(destChan.getLabel(), "java::ModuleYamlManager",
                                              "Update modules.yaml file");

        }
    }

}
